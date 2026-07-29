import Observation
import Foundation

@Observable
@MainActor
public final class RoutineLibraryViewModel {
    public private(set) var packs: [RoutinePack] = []
    public private(set) var pets: [Pet] = []
    public var selectedPetID: UUID?
    public private(set) var isApplying = false
    public var statusMessage: String?
    public var errorMessage: String?

    private let provider: StarterRoutineProvider
    private let loadPets: LoadPetsUseCase
    private let applyPack: ApplyRoutinePackUseCase

    public init(
        provider: StarterRoutineProvider = StarterRoutineProvider(),
        loadPets: LoadPetsUseCase,
        applyPack: ApplyRoutinePackUseCase
    ) {
        self.provider = provider
        self.loadPets = loadPets
        self.applyPack = applyPack
    }

    public func load() async {
        packs = provider.packs()
        do {
            pets = try await loadPets()
            if selectedPetID == nil { selectedPetID = pets.first?.id }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func addPack(_ pack: RoutinePack) async {
        guard let petID = selectedPetID else {
            errorMessage = "Add a pet before applying a pack."
            return
        }
        isApplying = true
        defer { isApplying = false }
        do {
            let created = try await applyPack(pack: pack, petID: petID)
            let petName = pets.first(where: { $0.id == petID })?.name ?? "pet"
            statusMessage = created.isEmpty
                ? "\(pack.title) already on \(petName)."
                : "Added \(created.count) to \(petName)."
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
