import Foundation

/// One row on today's card.
public struct TodayRow: Identifiable, Hashable, Sendable {
    public let routine: Routine
    public let petName: String
    public let isCompleted: Bool
    public let logID: UUID?

    public var id: UUID { routine.id }

    public init(routine: Routine, petName: String, isCompleted: Bool, logID: UUID?) {
        self.routine = routine
        self.petName = petName
        self.isCompleted = isCompleted
        self.logID = logID
    }
}

/// The today card: rows plus streak rail.
public struct TodayChecklist: Hashable, Sendable {
    public let date: Date
    public let rows: [TodayRow]
    public let streak: StreakRail
    public let completionRate: Double

    public init(date: Date, rows: [TodayRow], streak: StreakRail, completionRate: Double) {
        self.date = date
        self.rows = rows
        self.streak = streak
        self.completionRate = completionRate
    }
}

/// Activity count for one routine over a period.
public struct RoutineActivity: Identifiable, Hashable, Sendable {
    public let routineID: UUID
    public let title: String
    public let count: Int

    public var id: UUID { routineID }

    public init(routineID: UUID, title: String, count: Int) {
        self.routineID = routineID
        self.title = title
        self.count = count
    }
}
