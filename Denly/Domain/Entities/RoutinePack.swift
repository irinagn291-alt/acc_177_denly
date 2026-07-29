import Foundation

/// A named pack of starter routines.
public struct RoutinePack: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let title: String
    public let detail: String
    public let routines: [StarterRoutine]

    public init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        routines: [StarterRoutine]
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.routines = routines
    }
}
