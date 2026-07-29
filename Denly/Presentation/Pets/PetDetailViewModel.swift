import Observation
import Foundation
import PhotosUI
import SwiftUI

/// Loads one pet plaque: routines, recent logs, streak, notes, avatar.
@Observable
@MainActor
public final class PetDetailViewModel {
    public let petID: UUID
    public private(set) var pet: Pet?
    public private(set) var routines: [Routine] = []
    public private(set) var allLogs: [CareLog] = []
    public private(set) var recentLogs: [CareLog] = []
    public private(set) var streak: StreakRail = StreakRail(currentStreak: 0, notches: [])
    public private(set) var completedDays: Set<Date> = []
    public private(set) var isLoading = false
    public private(set) var didDelete = false
    public var errorMessage: String?
    public var editName = ""
    public var editSpecies = ""
    public var isEditing = false
    public var historyQuery = ""
    public var selectedPhoto: PhotosPickerItem?

    private let loadPet: LoadPetUseCase
    private let updatePet: UpdatePetUseCase
    private let deletePet: DeletePetUseCase
    private let loadRoutines: LoadRoutinesUseCase
    private let deleteRoutine: DeleteRoutineUseCase
    private let loadCareLogs: LoadCareLogsUseCase
    private let computeStreak: ComputeStreakUseCase
    private let updateCareNote: UpdateCareNoteUseCase
    private let filterHistory: FilterCareHistoryUseCase
    private let avatarStore: PetAvatarStore

    public init(
        petID: UUID,
        loadPet: LoadPetUseCase,
        updatePet: UpdatePetUseCase,
        deletePet: DeletePetUseCase,
        loadRoutines: LoadRoutinesUseCase,
        deleteRoutine: DeleteRoutineUseCase,
        loadCareLogs: LoadCareLogsUseCase,
        computeStreak: ComputeStreakUseCase,
        updateCareNote: UpdateCareNoteUseCase,
        filterHistory: FilterCareHistoryUseCase = FilterCareHistoryUseCase(),
        avatarStore: PetAvatarStore = PetAvatarStore()
    ) {
        self.petID = petID
        self.loadPet = loadPet
        self.updatePet = updatePet
        self.deletePet = deletePet
        self.loadRoutines = loadRoutines
        self.deleteRoutine = deleteRoutine
        self.loadCareLogs = loadCareLogs
        self.computeStreak = computeStreak
        self.updateCareNote = updateCareNote
        self.filterHistory = filterHistory
        self.avatarStore = avatarStore
    }

    public var filteredLogs: [CareLog] {
        filterHistory(logs: allLogs, query: historyQuery)
    }

    public func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let loaded = try await loadPet(id: petID)
            pet = loaded
            editName = loaded.name
            editSpecies = loaded.species
            let allRoutines = try await loadRoutines()
            routines = allRoutines
                .filter { $0.petID == petID }
                .sorted {
                    if $0.slot.sortOrder != $1.slot.sortOrder {
                        return $0.slot.sortOrder < $1.slot.sortOrder
                    }
                    return $0.position < $1.position
                }
            let logs = try await loadCareLogs()
            allLogs = logs
                .filter { $0.petID == petID }
                .sorted { $0.completedAt > $1.completedAt }
            recentLogs = Array(allLogs.prefix(12))
            let calendar = Calendar.current
            completedDays = Set(allLogs.map { calendar.startOfDay(for: $0.completedAt) })
            streak = try await computeStreak(petID: petID)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func saveEdits() async {
        guard var current = pet else { return }
        current.name = editName
        current.species = editSpecies
        do {
            pet = try await updatePet(current)
            isEditing = false
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func removePet() async {
        do {
            try await deletePet(id: petID)
            didDelete = true
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func removeRoutine(_ routine: Routine) async {
        do {
            try await deleteRoutine(id: routine.id)
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func saveNote(logID: UUID, note: String) async {
        do {
            _ = try await updateCareNote(logID: logID, note: note)
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func applySelectedPhoto() async {
        guard let selectedPhoto else { return }
        do {
            guard let data = try await selectedPhoto.loadTransferable(type: Data.self) else { return }
            let path = try avatarStore.saveJPEG(data, petID: petID)
            guard var current = pet else { return }
            current.avatarRelativePath = path
            pet = try await updatePet(current)
            self.selectedPhoto = nil
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func clearAvatar() async {
        guard var current = pet else { return }
        current.avatarRelativePath = nil
        do {
            pet = try await updatePet(current)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func log(id: UUID) -> CareLog? {
        allLogs.first { $0.id == id }
    }
}
