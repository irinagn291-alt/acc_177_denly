import CoreData
import Foundation

/// Owns the persistent container and hands out scoped access to a private context.
public final class DenlyDataStore: @unchecked Sendable {

    public enum Location: Sendable {
        case onDisk
        case inMemory
    }

    nonisolated(unsafe) private static let sharedModel: NSManagedObjectModel =
        DenlyModelBuilder.makeModel()

    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    public init(location: Location = .onDisk, name: String = "DenlyJournal") throws {
        container = NSPersistentContainer(name: name, managedObjectModel: Self.sharedModel)

        let description: NSPersistentStoreDescription
        switch location {
        case .inMemory:
            description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
        case .onDisk:
            description = container.persistentStoreDescriptions[0]
        }
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]

        if let loadError = Self.loadStores(into: container) {
            if location == .onDisk, let url = description.url {
                try? FileManager.default.removeItem(at: url)
                if let retryError = Self.loadStores(into: container) {
                    throw DenlyError.storeFailure(retryError.localizedDescription)
                }
            } else {
                throw DenlyError.storeFailure(loadError.localizedDescription)
            }
        }

        context = container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        context.automaticallyMergesChangesFromParent = true
    }

    public func perform<T: Sendable>(
        _ body: @escaping @Sendable (NSManagedObjectContext) throws -> T
    ) async throws -> T {
        let context = self.context
        return try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    continuation.resume(returning: try body(context))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private static func loadStores(into container: NSPersistentContainer) -> Error? {
        var captured: Error?
        container.loadPersistentStores { _, error in
            if let error { captured = error }
        }
        return captured
    }
}
