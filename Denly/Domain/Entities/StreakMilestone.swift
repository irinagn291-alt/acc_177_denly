import Foundation

/// Celebrated streak thresholds.
public enum StreakMilestone: Int, CaseIterable, Identifiable, Sendable, Hashable {
    case three = 3
    case seven = 7
    case fourteen = 14
    case thirty = 30

    public var id: Int { rawValue }

    public var title: String {
        switch self {
        case .three: return "First enamel"
        case .seven: return "Week rail"
        case .fourteen: return "Fortnight glaze"
        case .thirty: return "Month plaque"
        }
    }

    public var detail: String {
        switch self {
        case .three: return "Three solid care days in a row."
        case .seven: return "A full week of stamped routines."
        case .fourteen: return "Fourteen days without breaking the rail."
        case .thirty: return "A month of enamel discipline."
        }
    }
}

/// Milestone progress for the current streak.
public struct StreakMilestoneProgress: Hashable, Sendable {
    public let currentStreak: Int
    public let reached: [StreakMilestone]
    public let next: StreakMilestone?

    public init(currentStreak: Int, reached: [StreakMilestone], next: StreakMilestone?) {
        self.currentStreak = currentStreak
        self.reached = reached
        self.next = next
    }
}
