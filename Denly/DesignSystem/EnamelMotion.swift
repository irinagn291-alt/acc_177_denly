import Foundation
import SwiftUI

/// Motion for swipe stamp and streak counter.
public enum EnamelMotion {
    public static let stampPeakScale: CGFloat = 1.06
    public static let stampSettleDuration: Double = 0.28

    public static func stampSettle(reduceMotion: Bool) -> Animation {
        reduceMotion
            ? .easeOut(duration: 0.15)
            : .spring(response: 0.32, dampingFraction: 0.72)
    }

    public static func numberRoll(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .easeOut(duration: 0.22)
    }

    public static func rowSlide(reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeOut(duration: 0.18) : .easeInOut(duration: 0.24)
    }
}
