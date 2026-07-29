import Foundation
@testable import Denly

enum DenlyFixtures {
    static func pet(name: String = "Mochi", species: String = "Cat") -> Pet {
        Pet(name: name, species: species)
    }

    static func routine(petID: UUID, title: String = "Feed", slot: RoutineSlot = .morning) -> Routine {
        Routine(petID: petID, title: title, slot: slot, position: 0)
    }

    static func log(petID: UUID, routineID: UUID?, title: String, day: Date = Date()) -> CareLog {
        CareLog(petID: petID, routineID: routineID, title: title, completedAt: day)
    }
}

final class InMemoryPetRepository: PetRepository, @unchecked Sendable {
    private var pets: [UUID: Pet] = [:]
    private let lock = NSLock()

    func fetchAll() async throws -> [Pet] {
        lock.withLock { Array(pets.values).sorted { $0.name < $1.name } }
    }

    func fetch(id: UUID) async throws -> Pet? {
        lock.withLock { pets[id] }
    }

    func save(_ pet: Pet) async throws {
        lock.withLock { pets[pet.id] = pet }
    }

    func delete(id: UUID) async throws {
        lock.withLock { pets.removeValue(forKey: id) }
    }

    func count() async throws -> Int {
        lock.withLock { pets.count }
    }
}

final class InMemoryRoutineRepository: RoutineRepository, @unchecked Sendable {
    private var routines: [UUID: Routine] = [:]
    private let lock = NSLock()

    func fetchAll() async throws -> [Routine] {
        lock.withLock { Array(routines.values) }
    }

    func fetch(id: UUID) async throws -> Routine? {
        lock.withLock { routines[id] }
    }

    func fetchActive(for petID: UUID?) async throws -> [Routine] {
        lock.withLock {
            routines.values.filter { routine in
                routine.isActive && (petID == nil || routine.petID == petID)
            }
        }
    }

    func save(_ routine: Routine) async throws {
        lock.withLock { routines[routine.id] = routine }
    }

    func delete(id: UUID) async throws {
        lock.withLock { routines.removeValue(forKey: id) }
    }

    func count() async throws -> Int {
        lock.withLock { routines.count }
    }
}

final class InMemoryCareLogRepository: CareLogRepository, @unchecked Sendable {
    private var logs: [UUID: CareLog] = [:]
    private let lock = NSLock()

    func fetchAll() async throws -> [CareLog] {
        lock.withLock { Array(logs.values) }
    }

    func fetch(id: UUID) async throws -> CareLog? {
        lock.withLock { logs[id] }
    }

    func fetch(from start: Date, to end: Date) async throws -> [CareLog] {
        lock.withLock {
            logs.values.filter { $0.completedAt >= start && $0.completedAt < end }
        }
    }

    func fetch(on day: Date) async throws -> [CareLog] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: day)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
        return try await fetch(from: start, to: end)
    }

    func save(_ log: CareLog) async throws {
        lock.withLock { logs[log.id] = log }
    }

    func delete(id: UUID) async throws {
        lock.withLock { logs.removeValue(forKey: id) }
    }
}

final class InMemoryOnboardingStore: OnboardingStore, @unchecked Sendable {
    private var completed = false
    private let lock = NSLock()

    func hasCompletedOnboarding() -> Bool {
        lock.withLock { completed }
    }

    func markOnboardingComplete() {
        lock.withLock { completed = true }
    }

    func resetOnboarding() {
        lock.withLock { completed = false }
    }
}
