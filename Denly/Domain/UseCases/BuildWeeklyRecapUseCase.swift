import Foundation

/// Builds a weekly average, best day, and completion heatmap.
public struct BuildWeeklyRecapUseCase: Sendable {
    private let routineRepository: RoutineRepository
    private let careLogRepository: CareLogRepository
    private let weeklyAverage: ComputeWeeklyAverageUseCase
    private let bestDay: ComputeBestDayUseCase

    public init(
        routineRepository: RoutineRepository,
        careLogRepository: CareLogRepository,
        weeklyAverage: ComputeWeeklyAverageUseCase,
        bestDay: ComputeBestDayUseCase
    ) {
        self.routineRepository = routineRepository
        self.careLogRepository = careLogRepository
        self.weeklyAverage = weeklyAverage
        self.bestDay = bestDay
    }

    public func callAsFunction(
        referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) async throws -> WeeklyRecap {
        let average = try await weeklyAverage(referenceDate: referenceDate, calendar: calendar)
        let weekday = try await bestDay(referenceDate: referenceDate, calendar: calendar)
        let weekdayName = weekday.map { calendar.weekdaySymbols[$0 - 1] }
        let routines = try await routineRepository.fetchActive(for: nil)
        let routineCount = max(routines.count, 1)
        let days = DenlyCalendar.daysBack(7, from: referenceDate, calendar: calendar)
        var heatmap: [HeatmapDay] = []
        var stamped = 0
        for day in days {
            let logs = try await careLogRepository.fetch(on: day)
            let unique = Set(logs.compactMap(\.routineID)).count
            let rate = routines.isEmpty ? 0 : Double(unique) / Double(routineCount)
            heatmap.append(HeatmapDay(day: day, rate: rate))
            if rate >= 1 { stamped += 1 }
        }
        return WeeklyRecap(
            averageRate: average,
            bestWeekday: weekday,
            bestWeekdayName: weekdayName,
            heatmap: heatmap,
            stampedDays: stamped
        )
    }
}
