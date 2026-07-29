import Foundation

/// Average daily completion rate over the past seven days.
public struct ComputeWeeklyAverageUseCase: Sendable {
    private let routineRepository: RoutineRepository
    private let careLogRepository: CareLogRepository

    public init(routineRepository: RoutineRepository, careLogRepository: CareLogRepository) {
        self.routineRepository = routineRepository
        self.careLogRepository = careLogRepository
    }

    public func callAsFunction(
        referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) async throws -> Double {
        let routines = try await routineRepository.fetchActive(for: nil)
        let routineCount = routines.count
        guard routineCount > 0 else { return 0 }

        let days = DenlyCalendar.daysBack(7, from: referenceDate, calendar: calendar)
        var rates: [Double] = []

        for day in days {
            let logs = try await careLogRepository.fetch(on: day)
            let uniqueRoutineIDs = Set(logs.compactMap(\.routineID))
            rates.append(Double(uniqueRoutineIDs.count) / Double(routineCount))
        }

        guard !rates.isEmpty else { return 0 }
        return rates.reduce(0, +) / Double(rates.count)
    }
}

/// Weekday with the highest completion rate.
public struct ComputeBestDayUseCase: Sendable {
    private let routineRepository: RoutineRepository
    private let careLogRepository: CareLogRepository

    public init(routineRepository: RoutineRepository, careLogRepository: CareLogRepository) {
        self.routineRepository = routineRepository
        self.careLogRepository = careLogRepository
    }

    public func callAsFunction(
        referenceDate: Date = Date(),
        lookbackDays: Int = 28,
        calendar: Calendar = .current
    ) async throws -> Int? {
        let routines = try await routineRepository.fetchActive(for: nil)
        let routineCount = routines.count
        guard routineCount > 0 else { return nil }

        var totals: [Int: (done: Int, total: Int)] = [:]
        let days = DenlyCalendar.daysBack(lookbackDays, from: referenceDate, calendar: calendar)

        for day in days {
            let weekday = calendar.component(.weekday, from: day)
            let logs = try await careLogRepository.fetch(on: day)
            let uniqueRoutineIDs = Set(logs.compactMap(\.routineID))
            var entry = totals[weekday, default: (0, 0)]
            entry.done += uniqueRoutineIDs.count
            entry.total += routineCount
            totals[weekday] = entry
        }

        let best = totals.max { lhs, rhs in
            let lhsRate = Double(lhs.value.done) / Double(max(lhs.value.total, 1))
            let rhsRate = Double(rhs.value.done) / Double(max(rhs.value.total, 1))
            return lhsRate < rhsRate
        }
        return best?.key
    }
}

/// Projects completion rate from recent trend.
public struct BuildForecastUseCase: Sendable {
    private let weeklyAverage: ComputeWeeklyAverageUseCase
    private let routineRepository: RoutineRepository
    private let careLogRepository: CareLogRepository

    public init(
        weeklyAverage: ComputeWeeklyAverageUseCase,
        routineRepository: RoutineRepository,
        careLogRepository: CareLogRepository
    ) {
        self.weeklyAverage = weeklyAverage
        self.routineRepository = routineRepository
        self.careLogRepository = careLogRepository
    }

    public func callAsFunction(referenceDate: Date = Date()) async throws -> Forecast {
        let rate = try await weeklyAverage(referenceDate: referenceDate)
        let focusSlot = try await weakestSlot(referenceDate: referenceDate)
        let percent = Int((rate * 100).rounded())
        let summary: String
        if rate >= 0.8 {
            summary = "On track — \(percent)% average this week."
        } else if rate >= 0.5 {
            summary = "Steady pace — \(percent)% average; focus on \(focusSlot?.badge ?? "evening")."
        } else {
            summary = "Room to grow — \(percent)% average; try shorter morning routines."
        }
        return Forecast(projectedRate: rate, focusSlot: focusSlot, summary: summary)
    }

    private func weakestSlot(referenceDate: Date) async throws -> RoutineSlot? {
        let routines = try await routineRepository.fetchActive(for: nil)
        guard !routines.isEmpty else { return nil }
        let logs = try await careLogRepository.fetch(
            from: DenlyCalendar.daysBack(7, from: referenceDate).first ?? referenceDate,
            to: referenceDate
        )
        let completedIDs = Set(logs.compactMap(\.routineID))
        var slotTotals: [RoutineSlot: (done: Int, total: Int)] = [:]
        for routine in routines {
            var entry = slotTotals[routine.slot, default: (0, 0)]
            entry.total += 1
            if completedIDs.contains(routine.id) { entry.done += 1 }
            slotTotals[routine.slot] = entry
        }
        return slotTotals.min { lhs, rhs in
            let l = Double(lhs.value.done) / Double(max(lhs.value.total, 1))
            let r = Double(rhs.value.done) / Double(max(rhs.value.total, 1))
            return l < r
        }?.key
    }
}

/// Generates short insights from journal data.
public struct BuildInsightsUseCase: Sendable {
    private let computeStreak: ComputeStreakUseCase
    private let weeklyAverage: ComputeWeeklyAverageUseCase
    private let bestDay: ComputeBestDayUseCase

    public init(
        computeStreak: ComputeStreakUseCase,
        weeklyAverage: ComputeWeeklyAverageUseCase,
        bestDay: ComputeBestDayUseCase
    ) {
        self.computeStreak = computeStreak
        self.weeklyAverage = weeklyAverage
        self.bestDay = bestDay
    }

    public func callAsFunction(referenceDate: Date = Date(), calendar: Calendar = .current) async throws -> [Insight] {
        var insights: [Insight] = []
        let streak = try await computeStreak(referenceDate: referenceDate, calendar: calendar)
        if streak.currentStreak > 0 {
            insights.append(Insight(
                kind: .streak,
                title: "\(streak.currentStreak) day streak",
                detail: "Every routine logged — keep the rail filled."
            ))
        }
        let average = try await weeklyAverage(referenceDate: referenceDate, calendar: calendar)
        let percent = Int((average * 100).rounded())
        insights.append(Insight(
            kind: .weekly,
            title: "\(percent)% weekly average",
            detail: "Completion rate across the last seven days."
        ))
        if let weekday = try await bestDay(referenceDate: referenceDate, calendar: calendar) {
            let name = calendar.weekdaySymbols[weekday - 1]
            insights.append(Insight(
                kind: .slot,
                title: "\(name)s shine",
                detail: "Your strongest day of the week for care routines."
            ))
        }
        if insights.isEmpty {
            insights.append(Insight(
                kind: .encouragement,
                title: "Start the rail",
                detail: "Add a pet and pick routines to begin your streak."
            ))
        }
        return insights
    }
}

/// Routine activity counts for charting.
public struct RoutineActivityUseCase: Sendable {
    private let routineRepository: RoutineRepository
    private let careLogRepository: CareLogRepository

    public init(routineRepository: RoutineRepository, careLogRepository: CareLogRepository) {
        self.routineRepository = routineRepository
        self.careLogRepository = careLogRepository
    }

    public func callAsFunction(
        referenceDate: Date = Date(),
        lookbackDays: Int = 7
    ) async throws -> [RoutineActivity] {
        let routines = try await routineRepository.fetchActive(for: nil)
        let start = DenlyCalendar.daysBack(lookbackDays, from: referenceDate).first ?? referenceDate
        let logs = try await careLogRepository.fetch(from: start, to: referenceDate)
        return routines.map { routine in
            let count = logs.filter { $0.routineID == routine.id }.count
            return RoutineActivity(routineID: routine.id, title: routine.title, count: count)
        }
        .sorted { $0.count > $1.count }
    }
}
