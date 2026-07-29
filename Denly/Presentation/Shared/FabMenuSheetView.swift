import SwiftUI

/// Deep FAB menu: Add Pet / Add Routine / Open Library / Export.
public struct FabMenuSheetView: View {
    let coordinator: DenlyCoordinator
    let onClose: () -> Void

    public init(coordinator: DenlyCoordinator, onClose: @escaping () -> Void) {
        self.coordinator = coordinator
        self.onClose = onClose
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: EnamelMetrics.inset) {
                menuRow(title: "Add Pet", systemImage: "pawprint.fill") {
                    onClose()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        coordinator.presentAddPet()
                    }
                }
                menuRow(title: "Add Routine", systemImage: "checklist") {
                    onClose()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        coordinator.presentAddRoutine()
                    }
                }
                menuRow(title: "Open Library", systemImage: "books.vertical.fill") {
                    onClose()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        coordinator.openRoutineLibrary()
                    }
                }
                menuRow(title: "Export", systemImage: "square.and.arrow.up") {
                    onClose()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        coordinator.presentExport()
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(EnamelMetrics.gutter)
            .enamelTexturedGround()
            .navigationTitle("Quick actions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: onClose)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func menuRow(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: EnamelMetrics.inset) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(EnamelPalette.cream)
                    .frame(width: 40, height: 40)
                    .background(EnamelPalette.green)
                    .clipShape(Circle())
                Text(title)
                    .font(EnamelType.bodyBold())
                    .foregroundStyle(EnamelPalette.ink)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(EnamelPalette.inkFaint)
            }
            .padding(EnamelMetrics.inset)
            .background(Color.white.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous))
            .modifier(EnamelStroke(color: EnamelPalette.ink.opacity(0.25)))
        }
        .buttonStyle(.plain)
    }
}
