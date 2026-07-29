import Observation
import Foundation

@Observable
@MainActor
public final class ExportViewModel {
    public private(set) var csvText: String?
    public private(set) var isLoading = false
    public var errorMessage: String?

    private let exportCSV: ExportCSVUseCase

    public init(exportCSV: ExportCSVUseCase) {
        self.exportCSV = exportCSV
    }

    public func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            csvText = try await exportCSV()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

@Observable
@MainActor
public final class AddRoutineViewModel {
    public private(set) var pets: [Pet] = []
    public var selectedPetID: UUID?
    public var title = ""
    public var slot: RoutineSlot = .morning
    public var errorMessage: String?

    private let loadPets: LoadPetsUseCase
    private let createRoutine: CreateRoutineUseCase

    public init(loadPets: LoadPetsUseCase, createRoutine: CreateRoutineUseCase) {
        self.loadPets = loadPets
        self.createRoutine = createRoutine
    }

    public func load() async {
        do {
            pets = try await loadPets()
            selectedPetID = pets.first?.id
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func save() async -> Bool {
        guard let petID = selectedPetID else {
            errorMessage = "Select a pet first."
            return false
        }
        do {
            _ = try await createRoutine(petID: petID, title: title, slot: slot)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
