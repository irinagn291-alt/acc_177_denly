import CoreData
import Foundation

public final class CoreDataCareLogRepository: CareLogRepository {
    private let store: DenlyDataStore

    public init(store: DenlyDataStore) {
        self.store = store
    }

    public func fetchAll() async throws -> [CareLog] {
        try await store.perform { context in
            let request = NSFetchRequest<CareLogEntity>(entityName: DenlyEntityName.careLog)
            request.sortDescriptors = [NSSortDescriptor(key: "completedAt", ascending: false)]
            return try context.fetch(request).map(CareLogMapping.log(from:))
        }
    }

    public func fetch(id: UUID) async throws -> CareLog? {
        try await store.perform { context in
            try Self.row(id: id, in: context).map(CareLogMapping.log(from:))
        }
    }

    public func fetch(from start: Date, to end: Date) async throws -> [CareLog] {
        try await store.perform { context in
            let request = NSFetchRequest<CareLogEntity>(entityName: DenlyEntityName.careLog)
            request.predicate = NSPredicate(
                format: "completedAt >= %@ AND completedAt < %@",
                start as NSDate,
                end as NSDate
            )
            request.sortDescriptors = [NSSortDescriptor(key: "completedAt", ascending: true)]
            return try context.fetch(request).map(CareLogMapping.log(from:))
        }
    }

    public func fetch(on day: Date) async throws -> [CareLog] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: day)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
        return try await fetch(from: start, to: end)
    }

    public func save(_ log: CareLog) async throws {
        try await store.perform { context in
            guard let pet = try CoreDataRoutineRepository.petRow(id: log.petID, in: context) else {
                throw DenlyError.petNotFound(log.petID)
            }
            let entity = try Self.row(id: log.id, in: context) ?? CareLogEntity(context: context)
            CareLogMapping.apply(log, to: entity, pet: pet)
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

    private static func row(id: UUID, in context: NSManagedObjectContext) throws -> CareLogEntity? {
        let request = NSFetchRequest<CareLogEntity>(entityName: DenlyEntityName.careLog)
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
