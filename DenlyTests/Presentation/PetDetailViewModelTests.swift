import XCTest
@testable import Denly

@MainActor
final class PetDetailViewModelTests: XCTestCase {

    func test_givenPetWithRoutinesAndLogs_whenLoad_thenSurfacesPlaqueData() async throws {
        // Given
        let pets = InMemoryPetRepository()
        let routines = InMemoryRoutineRepository()
        let logs = InMemoryCareLogRepository()
        let pet = DenlyFixtures.pet(name: "Mochi", species: "Cat")
        try await pets.save(pet)
        let feed = DenlyFixtures.routine(petID: pet.id, title: "Feed", slot: .morning)
        let walk = DenlyFixtures.routine(petID: pet.id, title: "Walk", slot: .evening)
        try await routines.save(feed)
        try await routines.save(walk)
        try await logs.save(DenlyFixtures.log(petID: pet.id, routineID: feed.id, title: "Feed"))
        try await logs.save(DenlyFixtures.log(petID: pet.id, routineID: walk.id, title: "Walk"))

        let viewModel = makeViewModel(
            petID: pet.id,
            pets: pets,
            routines: routines,
            logs: logs
        )

        // When
        await viewModel.load()

        // Then
        XCTAssertEqual(viewModel.pet?.name, "Mochi")
        XCTAssertEqual(viewModel.routines.count, 2)
        XCTAssertEqual(viewModel.recentLogs.count, 2)
        XCTAssertEqual(viewModel.streak.currentStreak, 1)
        XCTAssertFalse(viewModel.completedDays.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }

    func test_givenMissingPet_whenLoad_thenSetsError() async {
        // Given
        let viewModel = makeViewModel(petID: UUID())

        // When
        await viewModel.load()

        // Then
        XCTAssertNil(viewModel.pet)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    func test_givenLoadedPet_whenSaveEdits_thenPersistsName() async throws {
        // Given
        let pets = InMemoryPetRepository()
        let pet = DenlyFixtures.pet(name: "Mochi")
        try await pets.save(pet)
        let viewModel = makeViewModel(petID: pet.id, pets: pets)
        await viewModel.load()
        viewModel.editName = "Bean"
        viewModel.editSpecies = "Dog"

        // When
        await viewModel.saveEdits()

        // Then
        XCTAssertEqual(viewModel.pet?.name, "Bean")
        XCTAssertEqual(viewModel.pet?.species, "Dog")
        XCTAssertFalse(viewModel.isEditing)
        let stored = try await pets.fetch(id: pet.id)
        XCTAssertEqual(stored?.name, "Bean")
    }

    func test_givenPet_whenRemove_thenMarksDeleted() async throws {
        // Given
        let pets = InMemoryPetRepository()
        let pet = DenlyFixtures.pet()
        try await pets.save(pet)
        let viewModel = makeViewModel(petID: pet.id, pets: pets)
        await viewModel.load()

        // When
        await viewModel.removePet()

        // Then
        XCTAssertTrue(viewModel.didDelete)
        let stored = try await pets.fetch(id: pet.id)
        XCTAssertNil(stored)
    }

    func test_givenRoutine_whenRemoveRoutine_thenReloadsWithoutIt() async throws {
        // Given
        let pets = InMemoryPetRepository()
        let routines = InMemoryRoutineRepository()
        let pet = DenlyFixtures.pet()
        try await pets.save(pet)
        let feed = DenlyFixtures.routine(petID: pet.id, title: "Feed")
        try await routines.save(feed)
        let viewModel = makeViewModel(petID: pet.id, pets: pets, routines: routines)
        await viewModel.load()
        XCTAssertEqual(viewModel.routines.count, 1)

        // When
        await viewModel.removeRoutine(feed)

        // Then
        XCTAssertTrue(viewModel.routines.isEmpty)
    }

    private func makeViewModel(
        petID: UUID,
        pets: InMemoryPetRepository = InMemoryPetRepository(),
        routines: InMemoryRoutineRepository = InMemoryRoutineRepository(),
        logs: InMemoryCareLogRepository = InMemoryCareLogRepository()
    ) -> PetDetailViewModel {
        PetDetailViewModel(
            petID: petID,
            loadPet: LoadPetUseCase(repository: pets),
            updatePet: UpdatePetUseCase(repository: pets),
            deletePet: DeletePetUseCase(repository: pets),
            loadRoutines: LoadRoutinesUseCase(repository: routines),
            deleteRoutine: DeleteRoutineUseCase(repository: routines),
            loadCareLogs: LoadCareLogsUseCase(repository: logs),
            computeStreak: ComputeStreakUseCase(
                routineRepository: routines,
                careLogRepository: logs
            ),
            updateCareNote: UpdateCareNoteUseCase(repository: logs)
        )
    }
}
