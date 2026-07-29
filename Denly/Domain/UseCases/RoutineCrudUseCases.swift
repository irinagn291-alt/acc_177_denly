import Foundation

public struct LoadRoutinesUseCase: Sendable {
    private let repository: RoutineRepository
    public init(repository: RoutineRepository) { self.repository = repository }
    public func callAsFunction() async throws -> [Routine] { try await repository.fetchAll() }
}

public struct LoadRoutineUseCase: Sendable {
    private let repository: RoutineRepository
    public init(repository: RoutineRepository) { self.repository = repository }
    public func callAsFunction(id: UUID) async throws -> Routine {
        guard let routine = try await repository.fetch(id: id) else {
            throw DenlyError.routineNotFound(id)
        }
        return routine
    }
}

public struct CreateRoutineUseCase: Sendable {
    private let repository: RoutineRepository
    public init(repository: RoutineRepository) { self.repository = repository }
    public func callAsFunction(
        petID: UUID,
        title: String,
        slot: RoutineSlot,
        position: Int = 0,
        now: Date = Date()
    ) async throws -> Routine {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw DenlyError.blankName }
        let routine = Routine(petID: petID, title: trimmed, slot: slot, position: position, createdAt: now)
        try await repository.save(routine)
        return routine
    }
}

public struct UpdateRoutineUseCase: Sendable {
    private let repository: RoutineRepository
    public init(repository: RoutineRepository) { self.repository = repository }
    public func callAsFunction(_ routine: Routine) async throws -> Routine {
        guard !routine.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DenlyError.blankName
        }
        try await repository.save(routine)
        return routine
    }
}

public struct DeleteRoutineUseCase: Sendable {
    private let repository: RoutineRepository
    public init(repository: RoutineRepository) { self.repository = repository }
    public func callAsFunction(id: UUID) async throws {
        guard try await repository.fetch(id: id) != nil else {
            throw DenlyError.routineNotFound(id)
        }
        try await repository.delete(id: id)
    }
}
