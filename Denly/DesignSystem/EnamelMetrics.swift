import SwiftUI

/// Geometry of the enamel sign.
public enum EnamelMetrics {
    public static let radius: CGFloat = 28
    public static let stroke: CGFloat = 2
    public static let gutter: CGFloat = 16
    public static let inset: CGFloat = 12
    public static let rowHeight: CGFloat = 56
    public static let notchSize: CGFloat = 10
    public static let fabSize: CGFloat = 56
    public static let tabBarHeight: CGFloat = 49
}

/// One-pixel misregistration offset for risograph texture.
public struct EnamelMisregister: ViewModifier {
    public init() {}
    public func body(content: Content) -> some View {
        content
            .background(
                content
                    .offset(x: 1, y: 1)
                    .blendMode(.multiply)
                    .opacity(0.06)
            )
    }
}

/// Two-point enamel stroke around a badge shape.
public struct EnamelStroke: ViewModifier {
    private let color: Color

    public init(color: Color = EnamelPalette.ink) {
        self.color = color
    }

    public func body(content: Content) -> some View {
        content
            .overlay {
                RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous)
                    .strokeBorder(color, lineWidth: EnamelMetrics.stroke)
            }
    }
}

extension View {
    public func enamelBadge(fill: Color = EnamelPalette.cream) -> some View {
        background(fill)
            .clipShape(RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous))
            .modifier(EnamelStroke())
            .modifier(EnamelMisregister())
    }

    public func enamelCard(fill: Color = .white.opacity(0.5)) -> some View {
        padding(EnamelMetrics.inset)
            .background(fill)
            .clipShape(RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous))
            .modifier(EnamelStroke(color: EnamelPalette.green.opacity(0.4)))
    }
}
