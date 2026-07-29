import XCTest
@testable import Denly

final class CareLogUseCaseTests: XCTestCase {
    private var pets: InMemoryPetRepository!
    private var routines: InMemoryRoutineRepository!
    private var logs: InMemoryCareLogRepository!

    override func setUp() {
        super.setUp()
        pets = InMemoryPetRepository()
        routines = InMemoryRoutineRepository()
        logs = InMemoryCareLogRepository()
    }

    func test_givenRoutine_whenLoggingForToday_thenLogIsCreated() async throws {
        let pet = DenlyFixtures.pet()
        try await pets.save(pet)
        let routine = DenlyFixtures.routine(petID: pet.id)
        try await routines.save(routine)
        let logCare = LogCareForDateUseCase(careLogRepository: logs, routineRepository: routines)
        let log = try await logCare(routineID: routine.id, on: Date())
        XCTAssertEqual(log.routineID, routine.id)
        XCTAssertEqual(log.title, routine.title)
    }

    func test_givenDuplicateLog_whenLoggingAgain_thenSameLogReturned() async throws {
        let pet = DenlyFixtures.pet()
        try await pets.save(pet)
        let routine = DenlyFixtures.routine(petID: pet.id)
        try await routines.save(routine)
        let logCare = LogCareForDateUseCase(careLogRepository: logs, routineRepository: routines)
        let first = try await logCare(routineID: routine.id, on: Date())
        let second = try await logCare(routineID: routine.id, on: Date())
        XCTAssertEqual(first.id, second.id)
    }

    func test_givenLog_whenDeleting_thenItIsRemoved() async throws {
        let pet = DenlyFixtures.pet()
        try await pets.save(pet)
        let log = DenlyFixtures.log(petID: pet.id, routineID: nil, title: "Walk")
        try await logs.save(log)
        try await DeleteCareLogUseCase(repository: logs)(id: log.id)
        let fetched = try await logs.fetch(id: log.id)
        XCTAssertNil(fetched)
    }
}
