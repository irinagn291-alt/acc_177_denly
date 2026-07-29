import SwiftUI

/// Design system gallery — every token and component state.
public struct EnamelGalleryView: View {
    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: EnamelMetrics.gutter) {
                section("Colour") {
                    ForEach(EnamelPalette.inventory, id: \.name) { token in
                        HStack(spacing: EnamelMetrics.inset) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(token.color)
                                .frame(width: 44, height: 28)
                                .modifier(EnamelStroke())
                            Text(token.name)
                                .font(EnamelType.body(14))
                                .foregroundStyle(EnamelPalette.ink)
                            Spacer()
                        }
                    }
                }

                section("Type") {
                    Text("Rockwell 20 — title").font(EnamelType.title())
                    Text("SF Pro Rounded 16 — body").font(EnamelType.body())
                    Text("42").font(EnamelType.streak()).contentTransition(.numericText())
                }

                section("Components") {
                    EnamelButton("Primary action") {}
                    HStack {
                        PetAvatarBadge(name: "Mochi", species: "Cat")
                        SpeciesChip("Cat")
                        SlotBadge(slot: .morning)
                        EnamelProgressRing(progress: 0.72, size: 64)
                    }
                    StreakRailView(rail: StreakRail(
                        currentStreak: 5,
                        notches: (0..<7).map { i in
                            StreakNotch(
                                day: Calendar.current.date(byAdding: .day, value: i - 6, to: Date()) ?? Date(),
                                completed: i < 5
                            )
                        }
                    ))
                    CareCalendarStrip(completedDays: Set(
                        (0..<4).compactMap { Calendar.current.date(byAdding: .day, value: -$0, to: Date()) }
                            .map { Calendar.current.startOfDay(for: $0) }
                    ))
                    DoneStampOverlay(visible: true, reduceMotion: false)
                    EnamelEmptyState(title: "No routines", detail: "Swipe the deck to add some.")
                }

                section("Motion") {
                    Text("Stamp peak scale: \(EnamelMotion.stampPeakScale, specifier: "%.2f")")
                        .font(EnamelType.body(14))
                }
            }
            .padding(EnamelMetrics.gutter)
        }
        .enamelGround()
        .navigationTitle("Enamel Gallery")
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: EnamelMetrics.inset) {
            Text(title)
                .font(EnamelType.title())
                .foregroundStyle(EnamelPalette.ink)
            content()
        }
        .enamelCard()
    }
}

#Preview {
    NavigationStack { EnamelGalleryView() }
}
