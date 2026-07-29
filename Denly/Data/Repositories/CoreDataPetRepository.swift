import CoreData
import Foundation

public final class CoreDataPetRepository: PetRepository {
    private let store: DenlyDataStore

    public init(store: DenlyDataStore) {
        self.store = store
    }

    public func fetchAll() async throws -> [Pet] {
        try await store.perform { context in
            let request = NSFetchRequest<PetEntity>(entityName: DenlyEntityName.pet)
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            return try context.fetch(request).map(PetMapping.pet(from:))
        }
    }

    public func fetch(id: UUID) async throws -> Pet? {
        try await store.perform { context in
            try Self.row(id: id, in: context).map(PetMapping.pet(from:))
        }
    }

    public func save(_ pet: Pet) async throws {
        try await store.perform { context in
            let entity = try Self.row(id: pet.id, in: context) ?? PetEntity(context: context)
            PetMapping.apply(pet, to: entity)
            try Self.commit(context)
        }
    }

    public func delete(id: UUID) async throws {
        try await store.perform { context in
            guard let entity = try Self.row(id: id, in: context) else { return }
            context.delete(entity)
            try Self.commit(context)
        }
    }

    public func count() async throws -> Int {
        try await store.perform { context in
            let request = NSFetchRequest<PetEntity>(entityName: DenlyEntityName.pet)
            return try context.count(for: request)
        }
    }

    private static func row(id: UUID, in context: NSManagedObjectContext) throws -> PetEntity? {
        let request = NSFetchRequest<PetEntity>(entityName: DenlyEntityName.pet)
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    private static func commit(_ context: NSManagedObjectContext) throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw DenlyError.storeFailure(error.localizedDescription)
        }
    }
}
