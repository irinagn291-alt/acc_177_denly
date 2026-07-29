import Foundation

/// One notch on the streak rail.
public struct StreakNotch: Hashable, Sendable {
    public let day: Date
    public let completed: Bool

    public init(day: Date, completed: Bool) {
        self.day = day
        self.completed = completed
    }
}

/// Discrete day notches and the running streak count.
public struct StreakRail: Hashable, Sendable {
    public let currentStreak: Int
    public let notches: [StreakNotch]

    public init(currentStreak: Int, notches: [StreakNotch]) {
        self.currentStreak = currentStreak
        self.notches = notches
    }
}
