import Foundation

public struct LoadCareLogsUseCase: Sendable {
    private let repository: CareLogRepository
    public init(repository: CareLogRepository) { self.repository = repository }
    public func callAsFunction() async throws -> [CareLog] { try await repository.fetchAll() }
}

public struct CreateCareLogUseCase: Sendable {
    private let repository: CareLogRepository
    public init(repository: CareLogRepository) { self.repository = repository }
    public func callAsFunction(_ log: CareLog) async throws -> CareLog {
        let trimmed = log.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw DenlyError.blankName }
        var stamped = log
        stamped.title = trimmed
        try await repository.save(stamped)
        return stamped
    }
}

public struct UpdateCareLogUseCase: Sendable {
    private let repository: CareLogRepository
    public init(repository: CareLogRepository) { self.repository = repository }
    public func callAsFunction(_ log: CareLog) async throws -> CareLog {
        guard !log.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DenlyError.blankName
        }
        try await repository.save(log)
        return log
    }
}

public struct DeleteCareLogUseCase: Sendable {
    private let repository: CareLogRepository
    public init(repository: CareLogRepository) { self.repository = repository }
    public func callAsFunction(id: UUID) async throws {
        guard try await repository.fetch(id: id) != nil else {
            throw DenlyError.careLogNotFound(id)
        }
        try await repository.delete(id: id)
    }
}

/// Logs a routine completion for a specific calendar day.
public struct LogCareForDateUseCase: Sendable {
    private let careLogRepository: CareLogRepository
    private let routineRepository: RoutineRepository

    public init(careLogRepository: CareLogRepository, routineRepository: RoutineRepository) {
        self.careLogRepository = careLogRepository
        self.routineRepository = routineRepository
    }

    public func callAsFunction(
        routineID: UUID,
        on day: Date,
        now: Date = Date()
    ) async throws -> CareLog {
        guard let routine = try await routineRepository.fetch(id: routineID) else {
            throw DenlyError.routineNotFound(routineID)
        }
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: day)
        let existing = try await careLogRepository.fetch(on: dayStart)
        if let match = existing.first(where: { $0.routineID == routineID }) {
            return match
        }
        var completedAt = dayStart
        if calendar.isDateInToday(day) {
            completedAt = now
        } else {
            completedAt = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: dayStart) ?? dayStart
        }
        let log = CareLog(
            petID: routine.petID,
            routineID: routine.id,
            title: routine.title,
            completedAt: completedAt
        )
        try await careLogRepository.save(log)
        return log
    }

    /// Removes a routine completion for a day.
    public func undo(routineID: UUID, on day: Date) async throws {
        let dayStart = Calendar.current.startOfDay(for: day)
        let logs = try await careLogRepository.fetch(on: dayStart)
        if let match = logs.first(where: { $0.routineID == routineID }) {
            try await careLogRepository.delete(id: match.id)
        }
    }
}
