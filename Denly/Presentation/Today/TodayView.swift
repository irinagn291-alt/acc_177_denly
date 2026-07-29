import SwiftUI

/// Today enamel plaque: date hero, progress ring, streak rail, swipe-to-stamp rows.
public struct TodayView: View {
    @Bindable var viewModel: TodayViewModel
    @Bindable var coordinator: DenlyCoordinator
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var stampedID: UUID?

    public init(viewModel: TodayViewModel, coordinator: DenlyCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: EnamelMetrics.gutter) {
                if let checklist = viewModel.checklist {
                    heroPlaque(checklist)
                    CareCalendarStrip(
                        completedDays: completedDays(from: checklist),
                        referenceDate: checklist.date
                    )
                    sectionLabel("TODAY'S CARE")
                    if checklist.rows.isEmpty {
                        EnamelEmptyState(
                            title: "No routines today",
                            detail: "Add routines from the + button or open a pet plaque."
                        )
                    } else {
                        ForEach(checklist.rows) { row in
                            TodayRowView(
                                row: row,
                                isStamped: stampedID == row.id,
                                reduceMotion: reduceMotion
                            ) {
                                Task { await stamp(row) }
                            }
                        }
                    }
                } else if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 48)
                } else if let error = viewModel.errorMessage {
                    EnamelEmptyState(title: "Could not load today", detail: error)
                }
            }
            .padding(EnamelMetrics.gutter)
            .padding(.bottom, 88)
        }
        .enamelTexturedGround()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Denly")
                    .font(EnamelType.title())
                    .foregroundStyle(EnamelPalette.ink)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    coordinator.openGallery()
                } label: {
                    Text("Gallery")
                        .font(EnamelType.bodyBold(14))
                        .foregroundStyle(EnamelPalette.green)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.refresh() }
        .refreshable { await viewModel.refresh() }
        .alert("Today", isPresented: Binding(
            get: { viewModel.errorMessage != nil && viewModel.checklist != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: Hero

    private func heroPlaque(_ checklist: TodayChecklist) -> some View {
        VStack(alignment: .leading, spacing: EnamelMetrics.gutter) {
            EnamelHabitatPlaqueImage(height: 110)
                .overlay(alignment: .bottomLeading) {
                    Text("HABITAT")
                        .font(EnamelType.badge(10))
                        .foregroundStyle(EnamelPalette.cream)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(EnamelPalette.ink.opacity(0.45))
                        .clipShape(Capsule())
                        .padding(8)
                }

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TODAY")
                        .font(EnamelType.badge(11))
                        .foregroundStyle(EnamelPalette.cream.opacity(0.85))
                        .tracking(2)
                    Text(checklist.date.formatted(.dateTime.weekday(.wide)))
                        .font(EnamelType.title(26))
                        .foregroundStyle(EnamelPalette.cream)
                    Text(checklist.date.formatted(.dateTime.month(.wide).day().year()))
                        .font(EnamelType.body(15))
                        .foregroundStyle(EnamelPalette.cream.opacity(0.8))
                }
                Spacer()
                EnamelProgressRing(progress: checklist.completionRate, size: 92)
                    .colorScheme(.light)
                    .background {
                        Circle()
                            .fill(EnamelPalette.cream)
                            .padding(2)
                    }
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Streak")
                        .font(EnamelType.bodyBold(14))
                        .foregroundStyle(EnamelPalette.cream.opacity(0.85))
                    Spacer()
                    Text("\(checklist.streak.currentStreak)")
                        .font(EnamelType.streak(32))
                        .foregroundStyle(EnamelPalette.mustard)
                        .contentTransition(.numericText())
                        .animation(
                            EnamelMotion.numberRoll(reduceMotion: reduceMotion),
                            value: checklist.streak.currentStreak
                        )
                }
                enamelNotchRail(checklist.streak)
            }
            .padding(EnamelMetrics.inset)
            .background(EnamelPalette.ink.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            HStack {
                Text(completionCaption(checklist))
                    .font(EnamelType.body(14))
                    .foregroundStyle(EnamelPalette.cream.opacity(0.9))
                Spacer()
                Text("Swipe a row →")
                    .font(EnamelType.badge(11))
                    .foregroundStyle(EnamelPalette.mustard)
            }
        }
        .padding(EnamelMetrics.gutter)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                EnamelPalette.green
                Canvas { context, size in
                    for i in 0..<40 {
                        let x = CGFloat((i * 37) % Int(size.width))
                        let y = CGFloat((i * 53) % Int(size.height))
                        context.fill(
                            Path(ellipseIn: CGRect(x: x, y: y, width: 1, height: 1)),
                            with: .color(EnamelPalette.cream.opacity(0.06))
                        )
                    }
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous)
                .strokeBorder(EnamelPalette.ink, lineWidth: EnamelMetrics.stroke)
        }
        .overlay {
            RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous)
                .strokeBorder(EnamelPalette.mustard.opacity(0.35), lineWidth: 1)
                .offset(x: 1, y: 1)
                .blendMode(.multiply)
                .allowsHitTesting(false)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(heroAccessibility(checklist))
    }

    private func enamelNotchRail(_ rail: StreakRail) -> some View {
        HStack(spacing: 6) {
            ForEach(Array(rail.notches.enumerated()), id: \.offset) { _, notch in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(notch.completed ? EnamelPalette.mustard : EnamelPalette.cream.opacity(0.25))
                    .frame(maxWidth: .infinity)
                    .frame(height: 18)
                    .overlay {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .strokeBorder(EnamelPalette.cream.opacity(0.35), lineWidth: 1)
                    }
            }
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(EnamelType.badge(11))
            .foregroundStyle(EnamelPalette.inkDim)
            .tracking(1.4)
    }

    private func completionCaption(_ checklist: TodayChecklist) -> String {
        let done = checklist.rows.filter(\.isCompleted).count
        let total = checklist.rows.count
        if total == 0 { return "Nothing scheduled" }
        return "\(done) of \(total) stamped"
    }

    private func heroAccessibility(_ checklist: TodayChecklist) -> String {
        "Today, \(Int((checklist.completionRate * 100).rounded())) percent complete, streak \(checklist.streak.currentStreak)"
    }

    private func completedDays(from checklist: TodayChecklist) -> Set<Date> {
        var days = Set(checklist.streak.notches.filter(\.completed).map(\.day))
        if checklist.completionRate >= 1 {
            days.insert(Calendar.current.startOfDay(for: checklist.date))
        }
        return days
    }

    private func stamp(_ row: TodayRow) async {
        withAnimation(EnamelMotion.stampSettle(reduceMotion: reduceMotion)) {
            stampedID = row.id
        }
        await viewModel.toggleComplete(row: row)
        if reduceMotion {
            stampedID = nil
        } else {
            try? await Task.sleep(for: .milliseconds(420))
            withAnimation(EnamelMotion.stampSettle(reduceMotion: false)) {
                stampedID = nil
            }
        }
    }
}

// MARK: - Row

private struct TodayRowView: View {
    let row: TodayRow
    let isStamped: Bool
    let reduceMotion: Bool
    let onSwipe: () -> Void

    @State private var offset: CGFloat = 0

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous)
                .fill(EnamelPalette.green.opacity(0.15))
            HStack {
                Spacer()
                Text("STAMP")
                    .font(EnamelType.badge(12))
                    .foregroundStyle(EnamelPalette.green)
                    .padding(.trailing, 20)
            }

            HStack(spacing: EnamelMetrics.inset) {
                SlotBadge(slot: row.routine.slot)
                VStack(alignment: .leading, spacing: 2) {
                    Text(row.routine.title)
                        .font(EnamelType.bodyBold())
                        .foregroundStyle(row.isCompleted ? EnamelPalette.inkFaint : EnamelPalette.ink)
                        .strikethrough(row.isCompleted, color: EnamelPalette.inkFaint)
                    Text(row.petName)
                        .font(EnamelType.body(13))
                        .foregroundStyle(EnamelPalette.inkDim)
                }
                Spacer()
                if row.isCompleted {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title3)
                        .foregroundStyle(EnamelPalette.green)
                        .accessibilityLabel("Completed")
                } else {
                    Image(systemName: "hand.draw")
                        .font(.body)
                        .foregroundStyle(EnamelPalette.inkFaint)
                        .accessibilityHidden(true)
                }
            }
            .padding(EnamelMetrics.inset)
            .frame(minHeight: EnamelMetrics.rowHeight)
            .background(row.isCompleted ? EnamelPalette.green.opacity(0.1) : Color.white.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous))
            .modifier(EnamelStroke(color: row.isCompleted ? EnamelPalette.green : EnamelPalette.ink.opacity(0.25)))
            .offset(x: offset)
            .overlay {
                DoneStampOverlay(visible: isStamped, reduceMotion: reduceMotion)
            }
            .scaleEffect(isStamped ? EnamelMotion.stampPeakScale : 1)
            .animation(EnamelMotion.stampSettle(reduceMotion: reduceMotion), value: isStamped)
        }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onChanged { value in
                    guard !row.isCompleted || value.translation.width < 0 else { return }
                    if value.translation.width > 0 && !row.isCompleted {
                        offset = min(value.translation.width, 96)
                    }
                }
                .onEnded { value in
                    if value.translation.width > 64 && !row.isCompleted {
                        withAnimation(EnamelMotion.rowSlide(reduceMotion: reduceMotion)) {
                            offset = 0
                        }
                        onSwipe()
                    } else if value.translation.width < -64 && row.isCompleted {
                        withAnimation(EnamelMotion.rowSlide(reduceMotion: reduceMotion)) {
                            offset = 0
                        }
                        onSwipe()
                    } else {
                        withAnimation(EnamelMotion.rowSlide(reduceMotion: reduceMotion)) {
                            offset = 0
                        }
                    }
                }
        )
        .accessibilityAction(named: row.isCompleted ? "Undo" : "Complete") { onSwipe() }
        .accessibilityHint(row.isCompleted ? "Marks this care incomplete" : "Marks this care done")
    }
}

#Preview {
    NavigationStack {
        TodayView(
            viewModel: DenlyContainer.preview().makeTodayViewModel(),
            coordinator: DenlyCoordinator()
        )
    }
}
