import Observation
import Foundation

/// Edits an existing care routine.
@Observable
@MainActor
public final class EditRoutineViewModel {
    public let routineID: UUID
    public private(set) var petName = ""
    public var title = ""
    public var slot: RoutineSlot = .morning
    public var isActive = true
    public private(set) var isLoading = false
    public var errorMessage: String?
    public private(set) var didSave = false

    private var routine: Routine?
    private let loadRoutine: LoadRoutineUseCase
    private let loadPet: LoadPetUseCase
    private let updateRoutine: UpdateRoutineUseCase
    private let deleteRoutine: DeleteRoutineUseCase

    public init(
        routineID: UUID,
        loadRoutine: LoadRoutineUseCase,
        loadPet: LoadPetUseCase,
        updateRoutine: UpdateRoutineUseCase,
        deleteRoutine: DeleteRoutineUseCase
    ) {
        self.routineID = routineID
        self.loadRoutine = loadRoutine
        self.loadPet = loadPet
        self.updateRoutine = updateRoutine
        self.deleteRoutine = deleteRoutine
    }

    public func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let loaded = try await loadRoutine(id: routineID)
            routine = loaded
            title = loaded.title
            slot = loaded.slot
            isActive = loaded.isActive
            if let pet = try? await loadPet(id: loaded.petID) {
                petName = pet.name
            }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func save() async -> Bool {
        guard var current = routine else { return false }
        current.title = title
        current.slot = slot
        current.isActive = isActive
        do {
            routine = try await updateRoutine(current)
            didSave = true
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    public func remove() async -> Bool {
        do {
            try await deleteRoutine(id: routineID)
            didSave = true
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
