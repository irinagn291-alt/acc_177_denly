import SwiftUI

/// Full-bleed enamel ground image under screen content.
public struct EnamelGroundView: View {
    public init() {}

    public var body: some View {
        Image("EnamelGround")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

/// Habitat plaque art for hero and onboarding.
public struct EnamelHabitatPlaqueImage: View {
    private let height: CGFloat

    public init(height: CGFloat = 140) {
        self.height = height
    }

    public var body: some View {
        Image("EnamelHabitatPlaque")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: EnamelMetrics.radius * 0.6, style: .continuous))
            .accessibilityHidden(true)
    }
}

extension View {
    /// Full-bleed enamel ground filling the available space.
    public func enamelGround() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
            .background { EnamelGroundView() }
    }
}
