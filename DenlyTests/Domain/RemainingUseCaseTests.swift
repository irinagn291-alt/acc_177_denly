import XCTest
@testable import Denly

final class RemainingUseCaseTests: XCTestCase {
    private var pets: InMemoryPetRepository!
    private var routines: InMemoryRoutineRepository!
    private var logs: InMemoryCareLogRepository!

    override func setUp() {
        super.setUp()
        pets = InMemoryPetRepository()
        routines = InMemoryRoutineRepository()
        logs = InMemoryCareLogRepository()
    }

    func test_givenPets_whenLoadingAll_thenTheyAreReturned() async throws {
        let pet = DenlyFixtures.pet()
        try await pets.save(pet)
        let all = try await LoadPetsUseCase(repository: pets)()
        XCTAssertEqual(all.count, 1)
    }

    func test_givenJournalIsEmpty_whenChecking_thenTrue() async throws {
        let empty = try await JournalIsEmptyUseCase(repository: pets)()
        XCTAssertTrue(empty)
    }

    func test_givenRoutine_whenUpdating_thenTitleChanges() async throws {
        let pet = DenlyFixtures.pet()
        try await pets.save(pet)
        var routine = DenlyFixtures.routine(petID: pet.id, title: "Feed")
        try await routines.save(routine)
        routine.title = "Dinner"
        _ = try await UpdateRoutineUseCase(repository: routines)(routine)
        let loaded = try await LoadRoutineUseCase(repository: routines)(id: routine.id)
        XCTAssertEqual(loaded.title, "Dinner")
    }

    func test_givenRoutines_whenLoadingAll_thenTheyAreReturned() async throws {
        let pet = DenlyFixtures.pet()
        try await pets.save(pet)
        try await routines.save(DenlyFixtures.routine(petID: pet.id))
        let all = try await LoadRoutinesUseCase(repository: routines)()
        XCTAssertEqual(all.count, 1)
    }

    func test_givenLog_whenUpdating_thenNotesChange() async throws {
        let pet = DenlyFixtures.pet()
        try await pets.save(pet)
        var log = DenlyFixtures.log(petID: pet.id, routineID: nil, title: "Walk")
        try await logs.save(log)
        log.notes = "Park"
        _ = try await UpdateCareLogUseCase(repository: logs)(log)
        let loaded = try await logs.fetch(id: log.id)
        XCTAssertEqual(loaded?.notes, "Park")
    }

    func test_givenLogs_whenLoadingAll_thenTheyAreReturned() async throws {
        let pet = DenlyFixtures.pet()
        try await pets.save(pet)
        try await logs.save(DenlyFixtures.log(petID: pet.id, routineID: nil, title: "Walk"))
        let all = try await LoadCareLogsUseCase(repository: logs)()
        XCTAssertEqual(all.count, 1)
    }

    func test_givenLogs_whenComputingBestDay_thenWeekdayReturned() async throws {
        let pet = DenlyFixtures.pet()
        try await pets.save(pet)
        let routine = DenlyFixtures.routine(petID: pet.id)
        try await routines.save(routine)
        let today = Calendar.current.startOfDay(for: Date())
        try await logs.save(DenlyFixtures.log(petID: pet.id, routineID: routine.id, title: "Feed", day: today))
        let weekday = try await ComputeBestDayUseCase(
            routineRepository: routines,
            careLogRepository: logs
        )(referenceDate: today)
        XCTAssertNotNil(weekday)
    }

    func test_givenActivity_whenComputing_thenCountsReturned() async throws {
        let pet = DenlyFixtures.pet()
        try await pets.save(pet)
        let routine = DenlyFixtures.routine(petID: pet.id, title: "Feed")
        try await routines.save(routine)
        try await logs.save(DenlyFixtures.log(petID: pet.id, routineID: routine.id, title: "Feed"))
        let activity = try await RoutineActivityUseCase(
            routineRepository: routines,
            careLogRepository: logs
        )()
        XCTAssertEqual(activity.first?.count, 1)
    }
}
