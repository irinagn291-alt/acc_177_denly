import XCTest
@testable import Denly

final class RoutineCrudUseCaseTests: XCTestCase {
    private var pets: InMemoryPetRepository!
    private var routines: InMemoryRoutineRepository!

    override func setUp() {
        super.setUp()
        pets = InMemoryPetRepository()
        routines = InMemoryRoutineRepository()
    }

    func test_givenPet_whenCreatingRoutine_thenItIsSaved() async throws {
        let pet = DenlyFixtures.pet()
        try await pets.save(pet)
        let create = CreateRoutineUseCase(repository: routines)
        let routine = try await create(petID: pet.id, title: "Feed", slot: .morning)
        let loaded = try await LoadRoutineUseCase(repository: routines)(id: routine.id)
        XCTAssertEqual(loaded.title, "Feed")
        XCTAssertEqual(loaded.slot, .morning)
    }

    func test_givenBlankTitle_whenCreatingRoutine_thenItThrows() async throws {
        let pet = DenlyFixtures.pet()
        try await pets.save(pet)
        let create = CreateRoutineUseCase(repository: routines)
        do {
            _ = try await create(petID: pet.id, title: "  ", slot: .evening)
            XCTFail("Expected blank name")
        } catch let error as DenlyError {
            XCTAssertEqual(error, .blankName)
        } catch {
            XCTFail("Unexpected error")
        }
    }

    func test_givenRoutine_whenDeleting_thenItIsGone() async throws {
        let pet = DenlyFixtures.pet()
        try await pets.save(pet)
        let routine = DenlyFixtures.routine(petID: pet.id)
        try await routines.save(routine)
        try await DeleteRoutineUseCase(repository: routines)(id: routine.id)
        let fetched = try await routines.fetch(id: routine.id)
        XCTAssertNil(fetched)
    }
}
