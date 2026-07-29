import Foundation

/// Shared calendar helpers for analytics use cases.
enum DenlyCalendar {
    static func dayStart(_ date: Date, calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: date)
    }

    static func daysBack(_ count: Int, from date: Date, calendar: Calendar = .current) -> [Date] {
        let start = dayStart(date, calendar: calendar)
        return (0..<count).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: start)
        }.reversed()
    }
}

/// Builds the today card with completion state and streak rail.
public struct LoadTodayChecklistUseCase: Sendable {
    private let petRepository: PetRepository
    private let routineRepository: RoutineRepository
    private let careLogRepository: CareLogRepository
    private let computeStreak: ComputeStreakUseCase

    public init(
        petRepository: PetRepository,
        routineRepository: RoutineRepository,
        careLogRepository: CareLogRepository,
        computeStreak: ComputeStreakUseCase
    ) {
        self.petRepository = petRepository
        self.routineRepository = routineRepository
        self.careLogRepository = careLogRepository
        self.computeStreak = computeStreak
    }

    public func callAsFunction(on date: Date = Date(), calendar: Calendar = .current) async throws -> TodayChecklist {
        let pets = try await petRepository.fetchAll()
        let petNames = Dictionary(uniqueKeysWithValues: pets.map { ($0.id, $0.name) })
        let routines = try await routineRepository.fetchActive(for: nil)
        let logs = try await careLogRepository.fetch(on: date)
        let completedIDs = Set(logs.compactMap(\.routineID))

        let rows = routines
            .sorted {
                if $0.slot.sortOrder != $1.slot.sortOrder { return $0.slot.sortOrder < $1.slot.sortOrder }
                return $0.position < $1.position
            }
            .map { routine in
                let log = logs.first { $0.routineID == routine.id }
                return TodayRow(
                    routine: routine,
                    petName: petNames[routine.petID] ?? "Pet",
                    isCompleted: completedIDs.contains(routine.id),
                    logID: log?.id
                )
            }

        let streak = try await computeStreak(referenceDate: date, calendar: calendar)
        let total = rows.count
        let done = rows.filter(\.isCompleted).count
        let rate = total > 0 ? Double(done) / Double(total) : 0

        return TodayChecklist(date: date, rows: rows, streak: streak, completionRate: rate)
    }
}
