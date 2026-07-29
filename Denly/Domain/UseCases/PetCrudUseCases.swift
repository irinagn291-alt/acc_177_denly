import Foundation

public struct LoadPetsUseCase: Sendable {
    private let repository: PetRepository
    public init(repository: PetRepository) { self.repository = repository }
    public func callAsFunction() async throws -> [Pet] { try await repository.fetchAll() }
}

public struct LoadPetUseCase: Sendable {
    private let repository: PetRepository
    public init(repository: PetRepository) { self.repository = repository }
    public func callAsFunction(id: UUID) async throws -> Pet {
        guard let pet = try await repository.fetch(id: id) else {
            throw DenlyError.petNotFound(id)
        }
        return pet
    }
}

public struct CreatePetUseCase: Sendable {
    private let repository: PetRepository
    public init(repository: PetRepository) { self.repository = repository }
    public func callAsFunction(name: String, species: String = "", now: Date = Date()) async throws -> Pet {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw DenlyError.blankName }
        let pet = Pet(name: trimmed, species: species, createdAt: now)
        try await repository.save(pet)
        return pet
    }
}

public struct UpdatePetUseCase: Sendable {
    private let repository: PetRepository
    public init(repository: PetRepository) { self.repository = repository }
    public func callAsFunction(_ pet: Pet) async throws -> Pet {
        guard !pet.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DenlyError.blankName
        }
        try await repository.save(pet)
        return pet
    }
}

public struct DeletePetUseCase: Sendable {
    private let repository: PetRepository
    public init(repository: PetRepository) { self.repository = repository }
    public func callAsFunction(id: UUID) async throws {
        guard try await repository.fetch(id: id) != nil else {
            throw DenlyError.petNotFound(id)
        }
        try await repository.delete(id: id)
    }
}

public struct JournalIsEmptyUseCase: Sendable {
    private let repository: PetRepository
    public init(repository: PetRepository) { self.repository = repository }
    public func callAsFunction() async throws -> Bool {
        try await repository.count() == 0
    }
}
