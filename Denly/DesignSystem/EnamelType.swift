import SwiftUI

/// Rockwell titles and SF Pro Rounded body.
public enum EnamelType {
    public static func title(_ size: CGFloat = 20, relativeTo textStyle: Font.TextStyle = .title3) -> Font {
        .custom("Rockwell", size: size, relativeTo: textStyle)
    }

    public static func body(_ size: CGFloat = 16, relativeTo textStyle: Font.TextStyle = .body) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }

    public static func bodyBold(_ size: CGFloat = 16, relativeTo textStyle: Font.TextStyle = .body) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    public static func streak(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .bold, design: .rounded).monospacedDigit()
    }

    public static func badge(_ size: CGFloat = 11) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
}
