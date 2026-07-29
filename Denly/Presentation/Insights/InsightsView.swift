import SwiftUI
import SwiftUICharts

/// Analytics enamel panels: forecast plaque, activity chart, insight chips.
public struct InsightsView: View {
    @Bindable var viewModel: InsightsViewModel
    @Bindable var coordinator: DenlyCoordinator

    public init(viewModel: InsightsViewModel, coordinator: DenlyCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: EnamelMetrics.gutter) {
                headerChrome

                if viewModel.isLoading && viewModel.forecast == nil && viewModel.insights.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else if isEmptyJournal {
                    EnamelEmptyState(
                        title: "No ink yet",
                        detail: "Stamp a few care days and the forecast plaque will fill in."
                    )
                } else {
                    if let forecast = viewModel.forecast {
                        forecastPlaque(forecast)
                    }
                    linkRow
                    activityPanel
                    insightsPanel
                }

                EnamelButton("Export CSV") {
                    coordinator.presentExport()
                }
            }
            .padding(EnamelMetrics.gutter)
            .padding(.bottom, 88)
        }
        .enamelTexturedGround()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Insights")
                    .font(EnamelType.title())
                    .foregroundStyle(EnamelPalette.ink)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.refresh() }
        .refreshable { await viewModel.refresh() }
    }

    private var isEmptyJournal: Bool {
        viewModel.activity.isEmpty
            && viewModel.insights.isEmpty
            && (viewModel.forecast == nil || (viewModel.forecast?.projectedRate ?? 0) == 0)
    }

    private var headerChrome: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("ENAMEL READOUT")
                .font(EnamelType.badge(11))
                .foregroundStyle(EnamelPalette.inkDim)
                .tracking(1.4)
            Text("How care has been landing.")
                .font(EnamelType.body())
                .foregroundStyle(EnamelPalette.inkDim)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var linkRow: some View {
        VStack(spacing: EnamelMetrics.inset) {
            navigationChip(
                title: "Weekly Recap",
                detail: "Average, best day, heatmap",
                tint: EnamelPalette.green
            ) { coordinator.openWeeklyRecap() }
            navigationChip(
                title: "Streak Milestones",
                detail: "3 · 7 · 14 · 30 day enamel badges",
                tint: EnamelPalette.mustard
            ) { coordinator.openStreakMilestones() }
            navigationChip(
                title: "Reminders",
                detail: "Evening nudge preference",
                tint: EnamelPalette.redBrown
            ) { coordinator.openRemindersSetup() }
        }
    }

    private func navigationChip(
        title: String,
        detail: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: EnamelMetrics.inset) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(tint)
                    .frame(width: 8, height: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(EnamelType.bodyBold())
                        .foregroundStyle(EnamelPalette.ink)
                    Text(detail)
                        .font(EnamelType.body(13))
                        .foregroundStyle(EnamelPalette.inkDim)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(EnamelPalette.inkFaint)
            }
            .padding(EnamelMetrics.inset)
            .background(Color.white.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous))
            .modifier(EnamelStroke(color: tint.opacity(0.45)))
        }
        .buttonStyle(.plain)
    }

    private func forecastPlaque(_ forecast: Forecast) -> some View {
        VStack(alignment: .leading, spacing: EnamelMetrics.inset) {
            HStack(alignment: .firstTextBaseline) {
                Text("FORECAST")
                    .font(EnamelType.badge(11))
                    .foregroundStyle(EnamelPalette.cream.opacity(0.85))
                    .tracking(1.4)
                Spacer()
                if let slot = forecast.focusSlot {
                    Text(slot.badge)
                        .font(EnamelType.badge())
                        .foregroundStyle(EnamelPalette.ink)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(EnamelPalette.mustard)
                        .clipShape(Capsule())
                }
            }

            HStack(alignment: .center, spacing: EnamelMetrics.gutter) {
                EnamelProgressRing(progress: forecast.projectedRate, size: 80)
                    .background {
                        Circle().fill(EnamelPalette.cream).padding(2)
                    }
                VStack(alignment: .leading, spacing: 6) {
                    Text(forecast.summary)
                        .font(EnamelType.body())
                        .foregroundStyle(EnamelPalette.cream)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Projected pace")
                        .font(EnamelType.badge(11))
                        .foregroundStyle(EnamelPalette.mustard)
                }
            }
        }
        .padding(EnamelMetrics.gutter)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(EnamelPalette.redBrown)
        .clipShape(RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous))
        .modifier(EnamelStroke(color: EnamelPalette.ink))
        .modifier(EnamelMisregister())
    }

    private var activityPanel: some View {
        VStack(alignment: .leading, spacing: EnamelMetrics.inset) {
            Text("ROUTINE ACTIVITY")
                .font(EnamelType.badge(11))
                .foregroundStyle(EnamelPalette.inkDim)
                .tracking(1.2)

            if viewModel.activity.isEmpty {
                Text("No completions logged yet.")
                    .font(EnamelType.body(14))
                    .foregroundStyle(EnamelPalette.inkDim)
            } else {
                activityChart
                ForEach(viewModel.activity.prefix(5)) { item in
                    HStack {
                        Text(item.title)
                            .font(EnamelType.body(14))
                            .foregroundStyle(EnamelPalette.ink)
                        Spacer()
                        Text("\(item.count)")
                            .font(EnamelType.bodyBold(14))
                            .foregroundStyle(EnamelPalette.green)
                            .contentTransition(.numericText())
                    }
                }
            }
        }
        .padding(EnamelMetrics.inset)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous))
        .modifier(EnamelStroke(color: EnamelPalette.green.opacity(0.4)))
    }

    private var insightsPanel: some View {
        VStack(alignment: .leading, spacing: EnamelMetrics.inset) {
            Text("INSIGHTS")
                .font(EnamelType.badge(11))
                .foregroundStyle(EnamelPalette.inkDim)
                .tracking(1.2)

            if viewModel.insights.isEmpty {
                Text("Keep stamping — insights appear after a few days.")
                    .font(EnamelType.body(14))
                    .foregroundStyle(EnamelPalette.inkDim)
            } else {
                ForEach(viewModel.insights) { insight in
                    HStack(alignment: .top, spacing: EnamelMetrics.inset) {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(tint(for: insight.kind))
                            .frame(width: 6, height: 40)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(insight.title)
                                .font(EnamelType.bodyBold())
                                .foregroundStyle(EnamelPalette.ink)
                            Text(insight.detail)
                                .font(EnamelType.body(14))
                                .foregroundStyle(EnamelPalette.inkDim)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(EnamelMetrics.inset)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous))
        .modifier(EnamelStroke(color: EnamelPalette.mustard.opacity(0.5)))
    }

    private func tint(for kind: InsightKind) -> Color {
        switch kind {
        case .streak: return EnamelPalette.green
        case .slot: return EnamelPalette.mustard
        case .weekly: return EnamelPalette.redBrown
        case .encouragement: return EnamelPalette.ink
        }
    }

    @ViewBuilder
    private var activityChart: some View {
        let values = viewModel.chartValues
        let labels = viewModel.chartLabels
        if values.isEmpty {
            EmptyView()
        } else {
            let maxVal = max(values.max() ?? 1, 1)
            AxisLabels {
                ChartGrid {
                    BarChart()
                        .chartData(values)
                        .chartYRange(0...maxVal)
                        .chartStyle(ChartStyle(
                            backgroundColor: .clear,
                            foregroundColor: ColorGradient(EnamelPalette.green, EnamelPalette.green)
                        ))
                }
                .chartGridLines(horizontal: 4, vertical: 0)
            }
            .chartXAxisLabels(labels, range: 1...max(labels.count, 1))
            .chartAxisColor(EnamelPalette.inkDim)
            .chartAxisFont(EnamelType.body(10))
            .frame(height: 180)
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    NavigationStack {
        InsightsView(
            viewModel: DenlyContainer.preview().makeInsightsViewModel(),
            coordinator: DenlyCoordinator()
        )
    }
}
