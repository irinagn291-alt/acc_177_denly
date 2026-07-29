import Foundation

/// Computes discrete streak notches and the running count.
public struct ComputeStreakUseCase: Sendable {
    private let routineRepository: RoutineRepository
    private let careLogRepository: CareLogRepository

    public init(
        routineRepository: RoutineRepository,
        careLogRepository: CareLogRepository
    ) {
        self.routineRepository = routineRepository
        self.careLogRepository = careLogRepository
    }

    public func callAsFunction(
        petID: UUID? = nil,
        referenceDate: Date = Date(),
        notchCount: Int = 7,
        calendar: Calendar = .current
    ) async throws -> StreakRail {
        let routines = try await routineRepository.fetchActive(for: petID)
        let routineIDs = Set(routines.map(\.id))
        let routineCount = routineIDs.count
        guard routineCount > 0 else {
            return StreakRail(currentStreak: 0, notches: [])
        }

        let days = DenlyCalendar.daysBack(notchCount, from: referenceDate, calendar: calendar)
        var notches: [StreakNotch] = []

        for day in days {
            let logs = try await careLogRepository.fetch(on: day)
            let uniqueRoutineIDs = Set(logs.compactMap(\.routineID)).intersection(routineIDs)
            let completed = uniqueRoutineIDs.count >= routineCount
            notches.append(StreakNotch(day: day, completed: completed))
        }

        var currentStreak = 0
        var cursor = DenlyCalendar.dayStart(referenceDate, calendar: calendar)
        while true {
            let logs = try await careLogRepository.fetch(on: cursor)
            let uniqueRoutineIDs = Set(logs.compactMap(\.routineID)).intersection(routineIDs)
            let completed = uniqueRoutineIDs.count >= routineCount
            if completed {
                currentStreak += 1
                guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
                cursor = previous
            } else {
                break
            }
        }

        return StreakRail(currentStreak: currentStreak, notches: notches)
    }
}
