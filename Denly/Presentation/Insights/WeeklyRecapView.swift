import SwiftUI

/// Weekly average, best day, and completion heatmap.
public struct WeeklyRecapView: View {
    @Bindable var viewModel: WeeklyRecapViewModel

    public init(viewModel: WeeklyRecapViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: EnamelMetrics.gutter) {
                Image("EnamelWeekRecapBanner")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 140)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous))
                    .modifier(EnamelStroke())
                    .accessibilityHidden(true)

                if viewModel.isLoading && viewModel.recap == nil {
                    ProgressView().frame(maxWidth: .infinity).padding(.top, 40)
                } else if let recap = viewModel.recap {
                    statsRow(recap)
                    heatmap(recap)
                } else {
                    EnamelEmptyState(
                        title: "No week yet",
                        detail: viewModel.errorMessage ?? "Stamp a few days to fill the recap."
                    )
                }
            }
            .padding(EnamelMetrics.gutter)
        }
        .enamelTexturedGround()
        .navigationTitle("Weekly Recap")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.refresh() }
        .refreshable { await viewModel.refresh() }
    }

    private func statsRow(_ recap: WeeklyRecap) -> some View {
        HStack(spacing: EnamelMetrics.inset) {
            statTile(
                label: "Average",
                value: "\(Int((recap.averageRate * 100).rounded()))%"
            )
            statTile(
                label: "Best day",
                value: recap.bestWeekdayName ?? "—"
            )
            statTile(
                label: "Full days",
                value: "\(recap.stampedDays)"
            )
        }
    }

    private func statTile(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(EnamelType.badge(10))
                .foregroundStyle(EnamelPalette.inkDim)
            Text(value)
                .font(EnamelType.streak(22))
                .foregroundStyle(EnamelPalette.green)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(EnamelMetrics.inset)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous))
        .modifier(EnamelStroke(color: EnamelPalette.green.opacity(0.4)))
    }

    private func heatmap(_ recap: WeeklyRecap) -> some View {
        VStack(alignment: .leading, spacing: EnamelMetrics.inset) {
            Text("COMPLETION HEATMAP")
                .font(EnamelType.badge(11))
                .foregroundStyle(EnamelPalette.inkDim)
                .tracking(1.2)

            HStack(spacing: 8) {
                ForEach(recap.heatmap) { day in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(heatColor(day.rate))
                            .frame(height: 56)
                            .overlay {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .strokeBorder(EnamelPalette.ink.opacity(0.2), lineWidth: 1)
                            }
                        Text(day.day.formatted(.dateTime.weekday(.narrow)))
                            .font(EnamelType.badge(11))
                            .foregroundStyle(EnamelPalette.inkDim)
                        Text("\(Int((day.rate * 100).rounded()))")
                            .font(EnamelType.body(11))
                            .foregroundStyle(EnamelPalette.ink)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(EnamelMetrics.inset)
        .background(Color.white.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous))
        .modifier(EnamelStroke(color: EnamelPalette.mustard.opacity(0.5)))
    }

    private func heatColor(_ rate: Double) -> Color {
        if rate >= 1 { return EnamelPalette.green }
        if rate >= 0.5 { return EnamelPalette.mustard.opacity(0.85) }
        if rate > 0 { return EnamelPalette.redBrown.opacity(0.55) }
        return EnamelPalette.ink.opacity(0.08)
    }
}

#Preview {
    NavigationStack {
        WeeklyRecapView(viewModel: DenlyContainer.preview().makeWeeklyRecapViewModel())
    }
}
