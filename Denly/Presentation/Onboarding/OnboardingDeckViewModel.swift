import Observation
import Foundation

@Observable
@MainActor
public final class OnboardingDeckViewModel {
    public private(set) var deck: [StarterRoutine] = []
    public private(set) var kept: [StarterRoutine] = []
    public var petName = ""
    public var petSpecies = ""
    public private(set) var isSaving = false
    public var errorMessage: String?

    private let createPet: CreatePetUseCase
    private let createRoutine: CreateRoutineUseCase
    private let onboardingStore: OnboardingStore
    private let templates: StarterRoutineProvider

    public init(
        createPet: CreatePetUseCase,
        createRoutine: CreateRoutineUseCase,
        onboardingStore: OnboardingStore,
        templates: StarterRoutineProvider
    ) {
        self.createPet = createPet
        self.createRoutine = createRoutine
        self.onboardingStore = onboardingStore
        self.templates = templates
        self.deck = templates.templates()
    }

    public var currentCard: StarterRoutine? { deck.first }

    public func keepCurrent() {
        guard let card = deck.first else { return }
        kept.append(card)
        deck.removeFirst()
    }

    public func discardCurrent() {
        guard !deck.isEmpty else { return }
        deck.removeFirst()
    }

    public func finish() async -> Bool {
        isSaving = true
        defer { isSaving = false }
        do {
            let pet = try await createPet(
                name: petName.isEmpty ? "My Pet" : petName,
                species: petSpecies
            )
            for (index, routine) in kept.enumerated() {
                _ = try await createRoutine(
                    petID: pet.id,
                    title: routine.title,
                    slot: routine.slot,
                    position: index
                )
            }
            onboardingStore.markOnboardingComplete()
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
