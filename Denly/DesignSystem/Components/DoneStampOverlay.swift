import SwiftUI

/// Visible "DONE" enamel stamp that settles after a swipe-complete.
public struct DoneStampOverlay: View {
    private let visible: Bool
    private let reduceMotion: Bool

    public init(visible: Bool, reduceMotion: Bool) {
        self.visible = visible
        self.reduceMotion = reduceMotion
    }

    public var body: some View {
        Image("EnamelDoneStamp")
            .resizable()
            .scaledToFit()
            .frame(width: 88, height: 88)
            .rotationEffect(.degrees(-12))
            .scaleEffect(visible ? 1 : (reduceMotion ? 1 : 1.4))
            .opacity(visible ? 0.92 : 0)
            .offset(x: visible ? 0 : 8, y: visible ? 0 : -6)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}
