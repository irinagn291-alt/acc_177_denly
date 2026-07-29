import Foundation

/// Adds every routine from a pack onto a pet.
public struct ApplyRoutinePackUseCase: Sendable {
    private let createRoutine: CreateRoutineUseCase
    private let loadRoutines: LoadRoutinesUseCase

    public init(createRoutine: CreateRoutineUseCase, loadRoutines: LoadRoutinesUseCase) {
        self.createRoutine = createRoutine
        self.loadRoutines = loadRoutines
    }

    public func callAsFunction(pack: RoutinePack, petID: UUID) async throws -> [Routine] {
        let existing = try await loadRoutines()
            .filter { $0.petID == petID }
        let existingTitles = Set(existing.map { $0.title.lowercased() })
        var created: [Routine] = []
        var position = existing.count
        for template in pack.routines {
            if existingTitles.contains(template.title.lowercased()) { continue }
            let routine = try await createRoutine(
                petID: petID,
                title: template.title,
                slot: template.slot,
                position: position
            )
            created.append(routine)
            position += 1
        }
        return created
    }
}
