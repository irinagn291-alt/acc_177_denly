import CoreData
import Foundation

@objc(PetEntity)
public final class PetEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var species: String
    @NSManaged public var createdAt: Date
    @NSManaged public var avatarRelativePath: String?
    @NSManaged public var routines: NSSet?
    @NSManaged public var careLogs: NSSet?
}

@objc(RoutineEntity)
public final class RoutineEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var slotRaw: String
    @NSManaged public var isActive: Bool
    @NSManaged public var position: Int16
    @NSManaged public var createdAt: Date
    @NSManaged public var pet: PetEntity?
}

@objc(CareLogEntity)
public final class CareLogEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var completedAt: Date
    @NSManaged public var notes: String
    @NSManaged public var routineID: UUID?
    @NSManaged public var pet: PetEntity?
}

public enum DenlyEntityName {
    public static let pet = "PetEntity"
    public static let routine = "RoutineEntity"
    public static let careLog = "CareLogEntity"
}
