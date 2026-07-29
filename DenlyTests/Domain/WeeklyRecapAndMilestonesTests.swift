import XCTest
@testable import Denly

final class WeeklyRecapAndMilestonesTests: XCTestCase {
    private var routines: InMemoryRoutineRepository!
    private var logs: InMemoryCareLogRepository!
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        routines = InMemoryRoutineRepository()
        logs = InMemoryCareLogRepository()
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar = cal
    }

    func test_givenLogsAcrossWeek_whenBuildingRecap_thenHeatmapHasSevenDays() async throws {
        let petID = UUID()
        let routine = DenlyFixtures.routine(petID: petID)
        try await routines.save(routine)
        let today = calendar.startOfDay(for: Date())
        try await logs.save(DenlyFixtures.log(
            petID: petID,
            routineID: routine.id,
            title: "Feed",
            day: today
        ))

        let recap = try await BuildWeeklyRecapUseCase(
            routineRepository: routines,
            careLogRepository: logs,
            weeklyAverage: ComputeWeeklyAverageUseCase(
                routineRepository: routines,
                careLogRepository: logs
            ),
            bestDay: ComputeBestDayUseCase(
                routineRepository: routines,
                careLogRepository: logs
            )
        )(referenceDate: today, calendar: calendar)

        XCTAssertEqual(recap.heatmap.count, 7)
        XCTAssertGreaterThan(recap.averageRate, 0)
        XCTAssertEqual(recap.stampedDays, 1)
    }

    func test_givenStreakCounts_whenEvaluatingMilestones_thenReachedAndNextAreCorrect() {
        let evaluate = EvaluateStreakMilestonesUseCase()

        let zero = evaluate(currentStreak: 0)
        XCTAssertTrue(zero.reached.isEmpty)
        XCTAssertEqual(zero.next, .three)

        let seven = evaluate(currentStreak: 7)
        XCTAssertEqual(seven.reached, [.three, .seven])
        XCTAssertEqual(seven.next, .fourteen)

        let thirty = evaluate(currentStreak: 30)
        XCTAssertEqual(thirty.reached.count, 4)
        XCTAssertNil(thirty.next)
    }

    func test_givenHistoryQuery_whenFiltering_thenMatchesTitleAndNotes() {
        let petID = UUID()
        let logs = [
            CareLog(petID: petID, title: "Morning feed", notes: "kibble"),
            CareLog(petID: petID, title: "Walk", notes: "park loop"),
            CareLog(petID: petID, title: "Brush", notes: "")
        ]
        let filter = FilterCareHistoryUseCase()
        XCTAssertEqual(filter(logs: logs, query: "feed").count, 1)
        XCTAssertEqual(filter(logs: logs, query: "park").count, 1)
        XCTAssertEqual(filter(logs: logs, query: "   ").count, 3)
    }
}
