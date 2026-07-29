import XCTest
@testable import Denly

final class ExportCSVUseCaseTests: XCTestCase {
    func test_givenLogs_whenExporting_thenCSVHasHeader() async throws {
        let pets = InMemoryPetRepository()
        let logs = InMemoryCareLogRepository()
        let pet = DenlyFixtures.pet()
        try await pets.save(pet)
        let log = DenlyFixtures.log(petID: pet.id, routineID: nil, title: "Walk")
        try await logs.save(log)
        let csv = try await ExportCSVUseCase(petRepository: pets, careLogRepository: logs)()
        XCTAssertTrue(csv.hasPrefix("date,pet,title,notes"))
        XCTAssertTrue(csv.contains("Mochi"))
        XCTAssertTrue(csv.contains("Walk"))
    }
}

final class LoadTodayChecklistUseCaseTests: XCTestCase {
    func test_givenRoutines_whenLoadingToday_thenRowsMatch() async throws {
        let pets = InMemoryPetRepository()
        let routines = InMemoryRoutineRepository()
        let logs = InMemoryCareLogRepository()
        let pet = DenlyFixtures.pet()
        try await pets.save(pet)
        let routine = DenlyFixtures.routine(petID: pet.id, title: "Feed")
        try await routines.save(routine)
        let load = LoadTodayChecklistUseCase(
            petRepository: pets,
            routineRepository: routines,
            careLogRepository: logs,
            computeStreak: ComputeStreakUseCase(routineRepository: routines, careLogRepository: logs)
        )
        let checklist = try await load()
        XCTAssertEqual(checklist.rows.count, 1)
        XCTAssertFalse(checklist.rows[0].isCompleted)
    }
}
