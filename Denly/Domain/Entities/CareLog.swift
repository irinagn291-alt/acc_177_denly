import Foundation

/// A completed care action on a calendar day.
public struct CareLog: Identifiable, Hashable, Sendable {
    public var id: UUID
    public var petID: UUID
    public var routineID: UUID?
    public var title: String
    public var completedAt: Date
    public var notes: String

    public init(
        id: UUID = UUID(),
        petID: UUID,
        routineID: UUID? = nil,
        title: String,
        completedAt: Date = Date(),
        notes: String = ""
    ) {
        self.id = id
        self.petID = petID
        self.routineID = routineID
        self.title = title
        self.completedAt = completedAt
        self.notes = notes
    }

    /// The calendar day this log belongs to.
    public var dayStart: Date {
        Calendar.current.startOfDay(for: completedAt)
    }
}
