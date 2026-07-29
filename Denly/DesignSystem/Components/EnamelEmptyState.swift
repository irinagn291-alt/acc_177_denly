import SwiftUI

/// Empty state for enamel screens with empty-care art.
public struct EnamelEmptyState: View {
    private let title: String
    private let detail: String

    public init(title: String, detail: String) {
        self.title = title
        self.detail = detail
    }

    public var body: some View {
        VStack(spacing: EnamelMetrics.inset) {
            Image("EnamelEmptyCare")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 180, maxHeight: 140)
                .accessibilityHidden(true)
            Text(title)
                .font(EnamelType.title())
                .foregroundStyle(EnamelPalette.ink)
            Text(detail)
                .font(EnamelType.body())
                .foregroundStyle(EnamelPalette.inkDim)
                .multilineTextAlignment(.center)
        }
        .padding(EnamelMetrics.gutter)
        .enamelBadge()
    }
}
