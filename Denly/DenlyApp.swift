import SwiftUI

@main
struct DenlyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

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
            if let container {
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
}
