import SwiftUI

/// Primary enamel button.
public struct EnamelButton: View {
    private let title: String
    private let action: () -> Void

    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(EnamelType.bodyBold())
                .foregroundStyle(EnamelPalette.cream)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(EnamelPalette.green)
                .clipShape(Capsule())
                .modifier(EnamelStroke(color: EnamelPalette.ink))
        }
        .buttonStyle(.plain)
    }
}

/// Slot badge for routine rows.
public struct SlotBadge: View {
    private let slot: RoutineSlot

    public init(slot: RoutineSlot) {
        self.slot = slot
    }

    public var body: some View {
        Text(slot.badge)
            .font(EnamelType.badge())
            .foregroundStyle(EnamelPalette.cream)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(EnamelPalette.mustard)
            .clipShape(Capsule())
    }
}
