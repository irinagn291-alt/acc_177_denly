import Foundation

/// Storage for routines.
public protocol RoutineRepository: Sendable {
    func fetchAll() async throws -> [Routine]
    func fetch(id: UUID) async throws -> Routine?
    func fetchActive(for petID: UUID?) async throws -> [Routine]
    func save(_ routine: Routine) async throws
    func delete(id: UUID) async throws
    func count() async throws -> Int
}
