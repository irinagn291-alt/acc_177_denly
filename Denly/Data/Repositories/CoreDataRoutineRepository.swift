import CoreData
import Foundation

public final class CoreDataRoutineRepository: RoutineRepository {
    private let store: DenlyDataStore

    public init(store: DenlyDataStore) {
        self.store = store
    }

    public func fetchAll() async throws -> [Routine] {
        try await store.perform { context in
            let request = NSFetchRequest<RoutineEntity>(entityName: DenlyEntityName.routine)
            request.sortDescriptors = [
                NSSortDescriptor(key: "position", ascending: true),
                NSSortDescriptor(key: "title", ascending: true)
            ]
            return try context.fetch(request).map(RoutineMapping.routine(from:))
        }
    }

    public func fetch(id: UUID) async throws -> Routine? {
        try await store.perform { context in
            try Self.row(id: id, in: context).map(RoutineMapping.routine(from:))
        }
    }

    public func fetchActive(for petID: UUID?) async throws -> [Routine] {
        try await store.perform { context in
            let request = NSFetchRequest<RoutineEntity>(entityName: DenlyEntityName.routine)
            request.predicate = NSPredicate(format: "isActive == YES")
            if let petID {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    NSPredicate(format: "isActive == YES"),
                    NSPredicate(format: "pet.id == %@", petID as CVarArg)
                ])
            }
            request.sortDescriptors = [
                NSSortDescriptor(key: "position", ascending: true)
            ]
            return try context.fetch(request).map(RoutineMapping.routine(from:))
        }
    }

    public func save(_ routine: Routine) async throws {
        try await store.perform { context in
            guard let pet = try Self.petRow(id: routine.petID, in: context) else {
                throw DenlyError.petNotFound(routine.petID)
            }
            let entity = try Self.row(id: routine.id, in: context) ?? RoutineEntity(context: context)
            RoutineMapping.apply(routine, to: entity, pet: pet)
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
            let request = NSFetchRequest<RoutineEntity>(entityName: DenlyEntityName.routine)
            return try context.count(for: request)
        }
    }

    static func row(id: UUID, in context: NSManagedObjectContext) throws -> RoutineEntity? {
        let request = NSFetchRequest<RoutineEntity>(entityName: DenlyEntityName.routine)
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    static func petRow(id: UUID, in context: NSManagedObjectContext) throws -> PetEntity? {
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
