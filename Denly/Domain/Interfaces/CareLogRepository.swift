import Foundation

/// Storage for care logs.
public protocol CareLogRepository: Sendable {
    func fetchAll() async throws -> [CareLog]
    func fetch(id: UUID) async throws -> CareLog?
    func fetch(from start: Date, to end: Date) async throws -> [CareLog]
    func fetch(on day: Date) async throws -> [CareLog]
    func save(_ log: CareLog) async throws
    func delete(id: UUID) async throws
}
