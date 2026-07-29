import Foundation

/// Starter routine template for onboarding.
public struct StarterRoutine: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let title: String
    public let slot: RoutineSlot

    public init(id: UUID = UUID(), title: String, slot: RoutineSlot) {
        self.id = id
        self.title = title
        self.slot = slot
    }
}

/// Provides swipe-deck starters and routine library packs.
public struct StarterRoutineProvider: Sendable {
    public init() {}

    public func templates() -> [StarterRoutine] {
        packs().flatMap(\.routines)
    }

    public func packs() -> [RoutinePack] {
        [
            RoutinePack(
                title: "Morning basics",
                detail: "Feed, water, and a gentle start.",
                routines: [
                    StarterRoutine(title: "Morning feed", slot: .morning),
                    StarterRoutine(title: "Fresh water", slot: .morning)
                ]
            ),
            RoutinePack(
                title: "Midday stretch",
                detail: "Movement and grooming between meals.",
                routines: [
                    StarterRoutine(title: "Midday walk", slot: .midday),
                    StarterRoutine(title: "Brush coat", slot: .midday)
                ]
            ),
            RoutinePack(
                title: "Evening wind-down",
                detail: "Play, meds, and a bedtime check.",
                routines: [
                    StarterRoutine(title: "Evening play", slot: .evening),
                    StarterRoutine(title: "Bedtime check", slot: .evening),
                    StarterRoutine(title: "Medication", slot: .evening)
                ]
            ),
            RoutinePack(
                title: "Litter & habitat",
                detail: "Keep the den fresh overnight.",
                routines: [
                    StarterRoutine(title: "Litter refresh", slot: .evening)
                ]
            )
        ]
    }
}
