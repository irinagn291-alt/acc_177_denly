import Foundation

/// Seeds sample data in the simulator when the journal is empty.
public struct SimulatorPetSeeder: Sendable {
    private let petRepository: PetRepository
    private let routineRepository: RoutineRepository

    public init(petRepository: PetRepository, routineRepository: RoutineRepository) {
        self.petRepository = petRepository
        self.routineRepository = routineRepository
    }

    public func seedIfEmpty() async throws {
        guard try await petRepository.count() == 0 else { return }
        let pet = Pet(name: "Mochi", species: "Cat")
        try await petRepository.save(pet)
        let starters = StarterRoutineProvider().templates().prefix(4)
        for (index, starter) in starters.enumerated() {
            let routine = Routine(
                petID: pet.id,
                title: starter.title,
                slot: starter.slot,
                position: index
            )
            try await routineRepository.save(routine)
        }
    }
}
