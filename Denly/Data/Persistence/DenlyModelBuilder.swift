import CoreData
import Foundation

/// Assembles the Core Data model in code.
public enum DenlyModelBuilder {

    public static func makeModel() -> NSManagedObjectModel {
        let pet = NSEntityDescription()
        pet.name = DenlyEntityName.pet
        pet.managedObjectClassName = NSStringFromClass(PetEntity.self)

        let routine = NSEntityDescription()
        routine.name = DenlyEntityName.routine
        routine.managedObjectClassName = NSStringFromClass(RoutineEntity.self)

        let careLog = NSEntityDescription()
        careLog.name = DenlyEntityName.careLog
        careLog.managedObjectClassName = NSStringFromClass(CareLogEntity.self)

        pet.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("name", .stringAttributeType),
            attribute("species", .stringAttributeType),
            attribute("createdAt", .dateAttributeType),
            attribute("avatarRelativePath", .stringAttributeType, optional: true)
        ]
        routine.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("title", .stringAttributeType),
            attribute("slotRaw", .stringAttributeType),
            attribute("isActive", .booleanAttributeType),
            attribute("position", .integer16AttributeType),
            attribute("createdAt", .dateAttributeType)
        ]
        careLog.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("title", .stringAttributeType),
            attribute("completedAt", .dateAttributeType),
            attribute("notes", .stringAttributeType),
            attribute("routineID", .UUIDAttributeType, optional: true)
        ]

        link(parent: pet, childName: "routines", child: routine, inverseName: "pet")
        link(parent: pet, childName: "careLogs", child: careLog, inverseName: "pet")

        pet.uniquenessConstraints = [["id"]]
        routine.uniquenessConstraints = [["id"]]
        careLog.uniquenessConstraints = [["id"]]

        let model = NSManagedObjectModel()
        model.entities = [pet, routine, careLog]
        return model
    }

    private static func attribute(
        _ name: String,
        _ type: NSAttributeType,
        optional: Bool = false
    ) -> NSAttributeDescription {
        let description = NSAttributeDescription()
        description.name = name
        description.attributeType = type
        description.isOptional = optional
        return description
    }

    private static func link(
        parent: NSEntityDescription,
        childName: String,
        child: NSEntityDescription,
        inverseName: String
    ) {
        let toMany = NSRelationshipDescription()
        toMany.name = childName
        toMany.destinationEntity = child
        toMany.minCount = 0
        toMany.maxCount = 0
        toMany.deleteRule = .cascadeDeleteRule
        toMany.isOptional = true

        let toOne = NSRelationshipDescription()
        toOne.name = inverseName
        toOne.destinationEntity = parent
        toOne.minCount = 0
        toOne.maxCount = 1
        toOne.deleteRule = .nullifyDeleteRule
        toOne.isOptional = true

        toMany.inverseRelationship = toOne
        toOne.inverseRelationship = toMany

        parent.properties.append(toMany)
        child.properties.append(toOne)
    }
}
