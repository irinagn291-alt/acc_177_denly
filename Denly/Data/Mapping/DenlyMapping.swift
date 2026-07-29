import CoreData
import Foundation

enum PetMapping {
    static func pet(from entity: PetEntity) -> Pet {
        Pet(
            id: entity.id,
            name: entity.name,
            species: entity.species,
            createdAt: entity.createdAt,
            avatarRelativePath: entity.avatarRelativePath
        )
    }

    static func apply(_ pet: Pet, to entity: PetEntity) {
        entity.id = pet.id
        entity.name = pet.name
        entity.species = pet.species
        entity.createdAt = pet.createdAt
        entity.avatarRelativePath = pet.avatarRelativePath
    }
}

enum RoutineMapping {
    static func routine(from entity: RoutineEntity) -> Routine {
        Routine(
            id: entity.id,
            petID: entity.pet?.id ?? UUID(),
            title: entity.title,
            slot: RoutineSlot(rawValue: entity.slotRaw) ?? .morning,
            isActive: entity.isActive,
            position: Int(entity.position),
            createdAt: entity.createdAt
        )
    }

    static func apply(_ routine: Routine, to entity: RoutineEntity, pet: PetEntity) {
        entity.id = routine.id
        entity.title = routine.title
        entity.slotRaw = routine.slot.rawValue
        entity.isActive = routine.isActive
        entity.position = Int16(routine.position)
        entity.createdAt = routine.createdAt
        entity.pet = pet
    }
}

enum CareLogMapping {
    static func log(from entity: CareLogEntity) -> CareLog {
        CareLog(
            id: entity.id,
            petID: entity.pet?.id ?? UUID(),
            routineID: entity.routineID,
            title: entity.title,
            completedAt: entity.completedAt,
            notes: entity.notes
        )
    }

    static func apply(_ log: CareLog, to entity: CareLogEntity, pet: PetEntity) {
        entity.id = log.id
        entity.title = log.title
        entity.completedAt = log.completedAt
        entity.notes = log.notes
        entity.routineID = log.routineID
        entity.pet = pet
    }
}
