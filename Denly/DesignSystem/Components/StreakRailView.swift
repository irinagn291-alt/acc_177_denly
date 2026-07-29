import SwiftUI

/// Discrete notches for the streak rail.
public struct StreakRailView: View {
    private let rail: StreakRail
    private let compact: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(rail: StreakRail, compact: Bool = false) {
        self.rail = rail
        self.compact = compact
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: compact ? 6 : 10) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(rail.currentStreak)")
                    .font(EnamelType.streak(compact ? 24 : 32))
                    .foregroundStyle(EnamelPalette.green)
                    .contentTransition(.numericText())
                    .animation(EnamelMotion.numberRoll(reduceMotion: reduceMotion), value: rail.currentStreak)
                VStack(alignment: .leading, spacing: 0) {
                    Text("day streak")
                        .font(EnamelType.bodyBold(13))
                        .foregroundStyle(EnamelPalette.inkDim)
                    if !rail.notches.isEmpty {
                        Text("\(rail.notches.filter(\.completed).count)/\(rail.notches.count) this week")
                            .font(EnamelType.badge(10))
                            .foregroundStyle(EnamelPalette.inkFaint)
                    }
                }
            }
            HStack(spacing: 5) {
                ForEach(Array(rail.notches.enumerated()), id: \.offset) { index, notch in
                    VStack(spacing: 3) {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(notch.completed ? EnamelPalette.green : EnamelPalette.cream)
                            .frame(
                                width: compact ? EnamelMetrics.notchSize : EnamelMetrics.notchSize + 2,
                                height: compact ? EnamelMetrics.notchSize * 2 : EnamelMetrics.notchSize * 2.4
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                    .strokeBorder(
                                        notch.completed ? EnamelPalette.ink.opacity(0.35) : EnamelPalette.ink.opacity(0.18),
                                        lineWidth: 1
                                    )
                            }
                            .overlay {
                                if notch.completed {
                                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                                        .strokeBorder(EnamelPalette.mustard.opacity(0.4), lineWidth: 1)
                                        .offset(x: 1, y: 1)
                                        .allowsHitTesting(false)
                                }
                            }
                        if !compact {
                            Text(weekday(notch.day))
                                .font(EnamelType.badge(9))
                                .foregroundStyle(
                                    index == rail.notches.count - 1
                                        ? EnamelPalette.ink
                                        : EnamelPalette.inkFaint
                                )
                        }
                    }
                    .accessibilityLabel(notch.completed ? "Completed" : "Missed")
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Streak \(rail.currentStreak) days")
    }

    private func weekday(_ day: Date) -> String {
        day.formatted(.dateTime.weekday(.narrow))
    }
}
