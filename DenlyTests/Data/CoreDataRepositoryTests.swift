import CoreData
import XCTest
@testable import Denly

final class CoreDataPetRepositoryTests: XCTestCase {
    private var store: DenlyDataStore!
    private var repository: CoreDataPetRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        store = try DenlyDataStore(location: .inMemory, name: "PetTest")
        repository = CoreDataPetRepository(store: store)
    }

    override func tearDown() {
        repository = nil
        store = nil
        super.tearDown()
    }

    func test_givenEmptyStore_whenFetching_thenNothingComesBack() async throws {
        let pets = try await repository.fetchAll()
        XCTAssertTrue(pets.isEmpty)
    }

    func test_givenPet_whenSavingAndFetching_thenFieldsSurvive() async throws {
        let pet = DenlyFixtures.pet()
        try await repository.save(pet)
        let loaded = try await repository.fetch(id: pet.id)
        XCTAssertEqual(loaded?.name, "Mochi")
        XCTAssertEqual(loaded?.species, "Cat")
    }

    func test_givenPet_whenDeleting_thenItIsGone() async throws {
        let pet = DenlyFixtures.pet()
        try await repository.save(pet)
        try await repository.delete(id: pet.id)
        let count = try await repository.count()
        XCTAssertEqual(count, 0)
    }
}

final class CoreDataRoutineRepositoryTests: XCTestCase {
    private var store: DenlyDataStore!
    private var petRepo: CoreDataPetRepository!
    private var routineRepo: CoreDataRoutineRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        store = try DenlyDataStore(location: .inMemory, name: "RoutineTest")
        petRepo = CoreDataPetRepository(store: store)
        routineRepo = CoreDataRoutineRepository(store: store)
    }

    func test_givenPetAndRoutine_whenSaving_thenRelationshipSurvives() async throws {
        let pet = DenlyFixtures.pet()
        try await petRepo.save(pet)
        let routine = DenlyFixtures.routine(petID: pet.id, title: "Walk", slot: .evening)
        try await routineRepo.save(routine)
        let loaded = try await routineRepo.fetch(id: routine.id)
        XCTAssertEqual(loaded?.title, "Walk")
        XCTAssertEqual(loaded?.slot, .evening)
        XCTAssertEqual(loaded?.petID, pet.id)
    }

    func test_givenInactiveRoutine_whenFetchingActive_thenItIsExcluded() async throws {
        let pet = DenlyFixtures.pet()
        try await petRepo.save(pet)
        var routine = DenlyFixtures.routine(petID: pet.id)
        routine.isActive = false
        try await routineRepo.save(routine)
        let active = try await routineRepo.fetchActive(for: nil)
        XCTAssertTrue(active.isEmpty)
    }
}

final class CoreDataCareLogRepositoryTests: XCTestCase {
    private var store: DenlyDataStore!
    private var petRepo: CoreDataPetRepository!
    private var logRepo: CoreDataCareLogRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        store = try DenlyDataStore(location: .inMemory, name: "LogTest")
        petRepo = CoreDataPetRepository(store: store)
        logRepo = CoreDataCareLogRepository(store: store)
    }

    func test_givenLog_whenSavingOnDay_thenFetchOnDayReturnsIt() async throws {
        let pet = DenlyFixtures.pet()
        try await petRepo.save(pet)
        let log = DenlyFixtures.log(petID: pet.id, routineID: nil, title: "Brush")
        try await logRepo.save(log)
        let today = try await logRepo.fetch(on: Date())
        XCTAssertEqual(today.count, 1)
        XCTAssertEqual(today.first?.title, "Brush")
    }
}

final class OnboardingStoreTests: XCTestCase {
    func test_givenFreshStore_whenChecking_thenNotComplete() {
        let store = InMemoryOnboardingStore()
        XCTAssertFalse(store.hasCompletedOnboarding())
    }

    func test_givenMarkedComplete_whenChecking_thenTrue() {
        let store = InMemoryOnboardingStore()
        store.markOnboardingComplete()
        XCTAssertTrue(store.hasCompletedOnboarding())
    }
}

final class SimulatorPetSeederTests: XCTestCase {
    func test_givenEmptyStore_whenSeeding_thenPetAndRoutinesAppear() async throws {
        let store = try DenlyDataStore(location: .inMemory, name: "SeedTest")
        let petRepo = CoreDataPetRepository(store: store)
        let routineRepo = CoreDataRoutineRepository(store: store)
        let seeder = SimulatorPetSeeder(petRepository: petRepo, routineRepository: routineRepo)
        try await seeder.seedIfEmpty()
        let count = try await petRepo.count()
        XCTAssertEqual(count, 1)
        let routines = try await routineRepo.fetchAll()
        XCTAssertEqual(routines.count, 4)
    }

    func test_givenExistingPet_whenSeeding_thenNothingChanges() async throws {
        let store = try DenlyDataStore(location: .inMemory, name: "SeedTest2")
        let petRepo = CoreDataPetRepository(store: store)
        let routineRepo = CoreDataRoutineRepository(store: store)
        try await petRepo.save(DenlyFixtures.pet(name: "Existing"))
        let seeder = SimulatorPetSeeder(petRepository: petRepo, routineRepository: routineRepo)
        try await seeder.seedIfEmpty()
        let count = try await petRepo.count()
        XCTAssertEqual(count, 1)
    }
}
