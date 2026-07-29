import SwiftUI

/// Celebrates 3 / 7 / 14 / 30 day streak enamel badges.
public struct StreakMilestonesView: View {
    @Bindable var viewModel: StreakMilestonesViewModel

    public init(viewModel: StreakMilestonesViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: EnamelMetrics.gutter) {
                if let progress = viewModel.progress {
                    header(progress)
                    ForEach(StreakMilestone.allCases) { milestone in
                        milestoneRow(milestone, reached: progress.reached.contains(milestone))
                    }
                    if let next = progress.next {
                        Text("Next enamel: \(next.title) at \(next.rawValue) days.")
                            .font(EnamelType.body(14))
                            .foregroundStyle(EnamelPalette.inkDim)
                    }
                } else if viewModel.isLoading {
                    ProgressView().frame(maxWidth: .infinity).padding(.top, 40)
                } else {
                    EnamelEmptyState(
                        title: "No milestones yet",
                        detail: viewModel.errorMessage ?? "Fill the streak rail to earn enamel badges."
                    )
                }
            }
            .padding(EnamelMetrics.gutter)
        }
        .enamelTexturedGround()
        .navigationTitle("Milestones")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.refresh() }
    }

    private func header(_ progress: StreakMilestoneProgress) -> some View {
        VStack(alignment: .leading, spacing: EnamelMetrics.inset) {
            HStack(alignment: .center, spacing: EnamelMetrics.gutter) {
                Image("EnamelMilestoneBadge")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88, height: 88)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 6) {
                    Text("CURRENT STREAK")
                        .font(EnamelType.badge(11))
                        .foregroundStyle(EnamelPalette.cream.opacity(0.85))
                        .tracking(1.2)
                    Text("\(progress.currentStreak)")
                        .font(EnamelType.streak(42))
                        .foregroundStyle(EnamelPalette.mustard)
                        .contentTransition(.numericText())
                    Text("^[\(progress.reached.count) badge](inflect: true) earned")
                        .font(EnamelType.body(14))
                        .foregroundStyle(EnamelPalette.cream.opacity(0.85))
                }
            }
        }
        .padding(EnamelMetrics.gutter)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(EnamelPalette.green)
        .clipShape(RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous))
        .modifier(EnamelStroke())
    }

    private func milestoneRow(_ milestone: StreakMilestone, reached: Bool) -> some View {
        HStack(spacing: EnamelMetrics.inset) {
            Image("EnamelMilestoneBadge")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .opacity(reached ? 1 : 0.28)
                .grayscale(reached ? 0 : 1)
            VStack(alignment: .leading, spacing: 4) {
                Text("\(milestone.rawValue) days — \(milestone.title)")
                    .font(EnamelType.bodyBold())
                    .foregroundStyle(reached ? EnamelPalette.ink : EnamelPalette.inkFaint)
                Text(milestone.detail)
                    .font(EnamelType.body(13))
                    .foregroundStyle(EnamelPalette.inkDim)
            }
            Spacer()
            if reached {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(EnamelPalette.green)
            }
        }
        .padding(EnamelMetrics.inset)
        .background(Color.white.opacity(reached ? 0.55 : 0.35))
        .clipShape(RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous))
        .modifier(EnamelStroke(color: reached ? EnamelPalette.green.opacity(0.5) : EnamelPalette.ink.opacity(0.15)))
    }
}

#Preview {
    NavigationStack {
        StreakMilestonesView(viewModel: DenlyContainer.preview().makeStreakMilestonesViewModel())
    }
}
