import SwiftUI

/// One-pixel risograph grain drawn in Canvas (transparent; sits over enamel ground).
public struct EnamelTextureGround: View {
    public init() {}

    public var body: some View {
        Canvas { context, size in
            let step: CGFloat = 7
            var y: CGFloat = 0
            while y < size.height {
                var x: CGFloat = 0
                while x < size.width {
                    let seed = Int(x * 13 + y * 29) & 7
                    if seed == 0 || seed == 3 {
                        let rect = CGRect(x: x + 1, y: y, width: 1, height: 1)
                        context.fill(
                            Path(ellipseIn: rect),
                            with: .color(EnamelPalette.ink.opacity(0.045))
                        )
                    }
                    if seed == 2 {
                        let rect = CGRect(x: x, y: y + 1, width: 1, height: 1)
                        context.fill(
                            Path(ellipseIn: rect),
                            with: .color(EnamelPalette.green.opacity(0.035))
                        )
                    }
                    x += step
                }
                y += step
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

extension View {
    /// Full-bleed enamel ground (image) with light grain overlay.
    public func enamelTexturedGround() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                ZStack {
                    EnamelGroundView()
                    EnamelTextureGround()
                        .opacity(0.35)
                }
            }
    }
}
