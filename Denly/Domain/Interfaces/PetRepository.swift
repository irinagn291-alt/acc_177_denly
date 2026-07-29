import Foundation

/// Storage for pets.
public protocol PetRepository: Sendable {
    func fetchAll() async throws -> [Pet]
    func fetch(id: UUID) async throws -> Pet?
    func save(_ pet: Pet) async throws
    func delete(id: UUID) async throws
    func count() async throws -> Int
}
