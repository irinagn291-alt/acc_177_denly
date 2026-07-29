import SwiftUI

/// Circular enamel progress plaque for today's completion.
public struct EnamelProgressRing: View {
    private let progress: Double
    private let size: CGFloat

    public init(progress: Double, size: CGFloat = 88) {
        self.progress = min(max(progress, 0), 1)
        self.size = size
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(EnamelPalette.cream, lineWidth: 10)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    EnamelPalette.green,
                    style: StrokeStyle(lineWidth: 10, lineCap: .butt)
                )
                .rotationEffect(.degrees(-90))
            Circle()
                .strokeBorder(EnamelPalette.ink.opacity(0.25), lineWidth: 1)
                .padding(4)
            VStack(spacing: 0) {
                Text("\(Int((progress * 100).rounded()))")
                    .font(EnamelType.streak(size * 0.28))
                    .foregroundStyle(EnamelPalette.ink)
                    .contentTransition(.numericText())
                Text("%")
                    .font(EnamelType.badge(10))
                    .foregroundStyle(EnamelPalette.inkDim)
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel("\(Int((progress * 100).rounded())) percent complete")
    }
}
