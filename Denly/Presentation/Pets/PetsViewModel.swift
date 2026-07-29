import Observation
import Foundation

@Observable
@MainActor
public final class PetsViewModel {
    public private(set) var pets: [Pet] = []
    public private(set) var routines: [Routine] = []
    public private(set) var isLoading = false
    public var errorMessage: String?

    private let loadPets: LoadPetsUseCase
    private let loadRoutines: LoadRoutinesUseCase
    private let createPet: CreatePetUseCase
    private let deletePet: DeletePetUseCase
    private let deleteRoutine: DeleteRoutineUseCase

    public init(
        loadPets: LoadPetsUseCase,
        loadRoutines: LoadRoutinesUseCase,
        createPet: CreatePetUseCase,
        deletePet: DeletePetUseCase,
        deleteRoutine: DeleteRoutineUseCase
    ) {
        self.loadPets = loadPets
        self.loadRoutines = loadRoutines
        self.createPet = createPet
        self.deletePet = deletePet
        self.deleteRoutine = deleteRoutine
    }

    public func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            pets = try await loadPets()
            routines = try await loadRoutines()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func addPet(name: String, species: String) async {
        do {
            _ = try await createPet(name: name, species: species)
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func removePet(_ pet: Pet) async {
        do {
            try await deletePet(id: pet.id)
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func removeRoutine(_ routine: Routine) async {
        do {
            try await deleteRoutine(id: routine.id)
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func routines(for pet: Pet) -> [Routine] {
        routines.filter { $0.petID == pet.id }
    }
}
