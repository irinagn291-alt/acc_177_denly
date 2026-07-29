import SwiftUI

/// The five enamel colours of the sign, and nothing else.
public enum EnamelPalette {
    public static let cream = Color(hex: 0xF2EDE1)
    public static let green = Color(hex: 0x2E5E4E)
    public static let redBrown = Color(hex: 0x9C4A32)
    public static let mustard = Color(hex: 0xC9973F)
    public static let ink = Color(hex: 0x20201E)

    public static let inkDim = ink.opacity(0.62)
    public static let inkFaint = ink.opacity(0.38)

    public static let inventory: [(name: String, color: Color)] = [
        ("cream", cream),
        ("green", green),
        ("red-brown", redBrown),
        ("mustard", mustard),
        ("ink", ink),
        ("ink dim", inkDim),
        ("ink faint", inkFaint)
    ]
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}
