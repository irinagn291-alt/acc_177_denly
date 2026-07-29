import Foundation

/// A repeatable care action tied to a pet and time slot.
public struct Routine: Identifiable, Hashable, Sendable {
    public var id: UUID
    public var petID: UUID
    public var title: String
    public var slot: RoutineSlot
    public var isActive: Bool
    public var position: Int
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        petID: UUID,
        title: String,
        slot: RoutineSlot,
        isActive: Bool = true,
        position: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.petID = petID
        self.title = title
        self.slot = slot
        self.isActive = isActive
        self.position = position
        self.createdAt = createdAt
    }
}
