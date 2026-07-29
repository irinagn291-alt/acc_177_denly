import Foundation

@MainActor
public final class DenlyContainer {
    public let store: DenlyDataStore
    public let petRepository: PetRepository
    public let routineRepository: RoutineRepository
    public let careLogRepository: CareLogRepository
    public let onboardingStore: OnboardingStore
    public let reminderStore: ReminderPreferencesStore
    public let reminderScheduler: ReminderScheduler

    public init(
        store: DenlyDataStore,
        onboardingStore: OnboardingStore = UserDefaultsOnboardingStore(),
        reminderStore: ReminderPreferencesStore = UserDefaultsReminderPreferencesStore(),
        reminderScheduler: ReminderScheduler = LocalReminderScheduler()
    ) {
        self.store = store
        self.petRepository = CoreDataPetRepository(store: store)
        self.routineRepository = CoreDataRoutineRepository(store: store)
        self.careLogRepository = CoreDataCareLogRepository(store: store)
        self.onboardingStore = onboardingStore
        self.reminderStore = reminderStore
        self.reminderScheduler = reminderScheduler
    }

    public static func preview() -> DenlyContainer {
        let store = try! DenlyDataStore(location: .inMemory)
        return DenlyContainer(
            store: store,
            onboardingStore: UserDefaultsOnboardingStore(
                defaults: UserDefaults(suiteName: "com.denly.pets.preview") ?? .standard
            ),
            reminderStore: UserDefaultsReminderPreferencesStore(
                defaults: UserDefaults(suiteName: "com.denly.pets.preview.reminders") ?? .standard
            ),
            reminderScheduler: NoOpReminderScheduler()
        )
    }

    // MARK: Use cases

    public var loadPets: LoadPetsUseCase { LoadPetsUseCase(repository: petRepository) }
    public var loadPet: LoadPetUseCase { LoadPetUseCase(repository: petRepository) }
    public var createPet: CreatePetUseCase { CreatePetUseCase(repository: petRepository) }
    public var updatePet: UpdatePetUseCase { UpdatePetUseCase(repository: petRepository) }
    public var deletePet: DeletePetUseCase { DeletePetUseCase(repository: petRepository) }
    public var journalIsEmpty: JournalIsEmptyUseCase { JournalIsEmptyUseCase(repository: petRepository) }

    public var loadRoutines: LoadRoutinesUseCase { LoadRoutinesUseCase(repository: routineRepository) }
    public var loadRoutine: LoadRoutineUseCase { LoadRoutineUseCase(repository: routineRepository) }
    public var createRoutine: CreateRoutineUseCase { CreateRoutineUseCase(repository: routineRepository) }
    public var updateRoutine: UpdateRoutineUseCase { UpdateRoutineUseCase(repository: routineRepository) }
    public var deleteRoutine: DeleteRoutineUseCase { DeleteRoutineUseCase(repository: routineRepository) }

    public var loadCareLogs: LoadCareLogsUseCase { LoadCareLogsUseCase(repository: careLogRepository) }
    public var createCareLog: CreateCareLogUseCase { CreateCareLogUseCase(repository: careLogRepository) }
    public var deleteCareLog: DeleteCareLogUseCase { DeleteCareLogUseCase(repository: careLogRepository) }
    public var updateCareNote: UpdateCareNoteUseCase { UpdateCareNoteUseCase(repository: careLogRepository) }

    public var logCareForDate: LogCareForDateUseCase {
        LogCareForDateUseCase(careLogRepository: careLogRepository, routineRepository: routineRepository)
    }

    public var computeStreak: ComputeStreakUseCase {
        ComputeStreakUseCase(routineRepository: routineRepository, careLogRepository: careLogRepository)
    }

    public var computeWeeklyAverage: ComputeWeeklyAverageUseCase {
        ComputeWeeklyAverageUseCase(routineRepository: routineRepository, careLogRepository: careLogRepository)
    }

    public var computeBestDay: ComputeBestDayUseCase {
        ComputeBestDayUseCase(routineRepository: routineRepository, careLogRepository: careLogRepository)
    }

    public var buildForecast: BuildForecastUseCase {
        BuildForecastUseCase(
            weeklyAverage: computeWeeklyAverage,
            routineRepository: routineRepository,
            careLogRepository: careLogRepository
        )
    }

    public var buildInsights: BuildInsightsUseCase {
        BuildInsightsUseCase(
            computeStreak: computeStreak,
            weeklyAverage: computeWeeklyAverage,
            bestDay: computeBestDay
        )
    }

    public var buildWeeklyRecap: BuildWeeklyRecapUseCase {
        BuildWeeklyRecapUseCase(
            routineRepository: routineRepository,
            careLogRepository: careLogRepository,
            weeklyAverage: computeWeeklyAverage,
            bestDay: computeBestDay
        )
    }

    public var loadStreakMilestones: LoadStreakMilestonesUseCase {
        LoadStreakMilestonesUseCase(computeStreak: computeStreak)
    }

    public var applyRoutinePack: ApplyRoutinePackUseCase {
        ApplyRoutinePackUseCase(createRoutine: createRoutine, loadRoutines: loadRoutines)
    }

    public var routineActivity: RoutineActivityUseCase {
        RoutineActivityUseCase(routineRepository: routineRepository, careLogRepository: careLogRepository)
    }

    public var loadTodayChecklist: LoadTodayChecklistUseCase {
        LoadTodayChecklistUseCase(
            petRepository: petRepository,
            routineRepository: routineRepository,
            careLogRepository: careLogRepository,
            computeStreak: computeStreak
        )
    }

    public var exportCSV: ExportCSVUseCase {
        ExportCSVUseCase(petRepository: petRepository, careLogRepository: careLogRepository)
    }

    // MARK: View models

    public func makeTodayViewModel() -> TodayViewModel {
        TodayViewModel(
            loadToday: loadTodayChecklist,
            logCare: logCareForDate,
            deleteCareLog: deleteCareLog
        )
    }

    public func makeInsightsViewModel() -> InsightsViewModel {
        InsightsViewModel(
            buildInsights: buildInsights,
            buildForecast: buildForecast,
            routineActivity: routineActivity
        )
    }

    public func makePetsViewModel() -> PetsViewModel {
        PetsViewModel(
            loadPets: loadPets,
            loadRoutines: loadRoutines,
            createPet: createPet,
            deletePet: deletePet,
            deleteRoutine: deleteRoutine
        )
    }

    public func makeOnboardingViewModel() -> OnboardingDeckViewModel {
        OnboardingDeckViewModel(
            createPet: createPet,
            createRoutine: createRoutine,
            onboardingStore: onboardingStore,
            templates: StarterRoutineProvider()
        )
    }

    public func makeExportViewModel() -> ExportViewModel {
        ExportViewModel(exportCSV: exportCSV)
    }

    public func makeAddRoutineViewModel() -> AddRoutineViewModel {
        AddRoutineViewModel(loadPets: loadPets, createRoutine: createRoutine)
    }

    public func makePetDetailViewModel(petID: UUID) -> PetDetailViewModel {
        PetDetailViewModel(
            petID: petID,
            loadPet: loadPet,
            updatePet: updatePet,
            deletePet: deletePet,
            loadRoutines: loadRoutines,
            deleteRoutine: deleteRoutine,
            loadCareLogs: loadCareLogs,
            computeStreak: computeStreak,
            updateCareNote: updateCareNote
        )
    }

    public func makeEditRoutineViewModel(routineID: UUID) -> EditRoutineViewModel {
        EditRoutineViewModel(
            routineID: routineID,
            loadRoutine: loadRoutine,
            loadPet: loadPet,
            updateRoutine: updateRoutine,
            deleteRoutine: deleteRoutine
        )
    }

    public func makeWeeklyRecapViewModel() -> WeeklyRecapViewModel {
        WeeklyRecapViewModel(buildRecap: buildWeeklyRecap)
    }

    public func makeStreakMilestonesViewModel() -> StreakMilestonesViewModel {
        StreakMilestonesViewModel(loadMilestones: loadStreakMilestones)
    }

    public func makeRoutineLibraryViewModel() -> RoutineLibraryViewModel {
        RoutineLibraryViewModel(loadPets: loadPets, applyPack: applyRoutinePack)
    }

    public func makeRemindersSetupViewModel() -> RemindersSetupViewModel {
        RemindersSetupViewModel(store: reminderStore, scheduler: reminderScheduler)
    }
}

/// Preview / test scheduler that does not touch the notification center.
public struct NoOpReminderScheduler: ReminderScheduler, Sendable {
    public init() {}
    public func apply(_ preference: ReminderPreference) async {}
}
