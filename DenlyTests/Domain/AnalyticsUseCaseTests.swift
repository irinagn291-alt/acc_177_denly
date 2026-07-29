import XCTest
@testable import Denly

final class AnalyticsUseCaseTests: XCTestCase {
    private var pets: InMemoryPetRepository!
    private var routines: InMemoryRoutineRepository!
    private var logs: InMemoryCareLogRepository!
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        pets = InMemoryPetRepository()
        routines = InMemoryRoutineRepository()
        logs = InMemoryCareLogRepository()
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar = cal
    }

    func test_givenAllRoutinesDone_whenComputingStreak_thenCountIsOne() async throws {
        let pet = DenlyFixtures.pet()
        try await pets.save(pet)
        let routine = DenlyFixtures.routine(petID: pet.id)
        try await routines.save(routine)
        let today = calendar.startOfDay(for: Date())
        let log = DenlyFixtures.log(petID: pet.id, routineID: routine.id, title: "Feed", day: today)
        try await logs.save(log)
        let streak = try await ComputeStreakUseCase(
            routineRepository: routines,
            careLogRepository: logs
        )(referenceDate: today, calendar: calendar)
        XCTAssertEqual(streak.currentStreak, 1)
        XCTAssertEqual(streak.notches.count, 7)
    }

    func test_givenNoRoutines_whenComputingWeeklyAverage_thenZero() async throws {
        let average = try await ComputeWeeklyAverageUseCase(
            routineRepository: routines,
            careLogRepository: logs
        )()
        XCTAssertEqual(average, 0)
    }

    func test_givenLogs_whenComputingWeeklyAverage_thenRateIsCorrect() async throws {
        let pet = DenlyFixtures.pet()
        try await pets.save(pet)
        let routine = DenlyFixtures.routine(petID: pet.id)
        try await routines.save(routine)
        let today = calendar.startOfDay(for: Date())
        let log = DenlyFixtures.log(petID: pet.id, routineID: routine.id, title: "Feed", day: today)
        try await logs.save(log)
        let average = try await ComputeWeeklyAverageUseCase(
            routineRepository: routines,
            careLogRepository: logs
        )(referenceDate: today, calendar: calendar)
        XCTAssertGreaterThan(average, 0)
        XCTAssertLessThanOrEqual(average, 1)
    }

    func test_givenInsights_whenBuilding_thenAtLeastOneReturned() async throws {
        let insights = try await BuildInsightsUseCase(
            computeStreak: ComputeStreakUseCase(routineRepository: routines, careLogRepository: logs),
            weeklyAverage: ComputeWeeklyAverageUseCase(routineRepository: routines, careLogRepository: logs),
            bestDay: ComputeBestDayUseCase(routineRepository: routines, careLogRepository: logs)
        )()
        XCTAssertFalse(insights.isEmpty)
    }

    func test_givenForecast_whenBuilding_thenSummaryIsNonEmpty() async throws {
        let forecast = try await BuildForecastUseCase(
            weeklyAverage: ComputeWeeklyAverageUseCase(routineRepository: routines, careLogRepository: logs),
            routineRepository: routines,
            careLogRepository: logs
        )()
        XCTAssertFalse(forecast.summary.isEmpty)
    }
}
