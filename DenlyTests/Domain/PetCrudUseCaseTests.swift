import XCTest
@testable import Denly

final class PetCrudUseCaseTests: XCTestCase {
    private var repository: InMemoryPetRepository!

    override func setUp() {
        super.setUp()
        repository = InMemoryPetRepository()
    }

    func test_givenEmptyStore_whenCreatingPet_thenItIsSaved() async throws {
        let create = CreatePetUseCase(repository: repository)
        let pet = try await create(name: "Mochi", species: "Cat")
        let loaded = try await LoadPetUseCase(repository: repository)(id: pet.id)
        XCTAssertEqual(loaded.name, "Mochi")
    }

    func test_givenBlankName_whenCreatingPet_thenItThrows() async {
        let create = CreatePetUseCase(repository: repository)
        do {
            _ = try await create(name: "   ")
            XCTFail("Expected blank name error")
        } catch let error as DenlyError {
            XCTAssertEqual(error, .blankName)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_givenPet_whenUpdating_thenNameChanges() async throws {
        let create = CreatePetUseCase(repository: repository)
        var pet = try await create(name: "Mochi")
        pet.name = "Bean"
        let update = UpdatePetUseCase(repository: repository)
        _ = try await update(pet)
        let loaded = try await LoadPetUseCase(repository: repository)(id: pet.id)
        XCTAssertEqual(loaded.name, "Bean")
    }

    func test_givenPet_whenDeleting_thenItIsGone() async throws {
        let create = CreatePetUseCase(repository: repository)
        let pet = try await create(name: "Mochi")
        try await DeletePetUseCase(repository: repository)(id: pet.id)
        let empty = try await JournalIsEmptyUseCase(repository: repository)()
        XCTAssertTrue(empty)
    }

    func test_givenMissingPet_whenLoading_thenItThrows() async {
        let load = LoadPetUseCase(repository: repository)
        let id = UUID()
        do {
            _ = try await load(id: id)
            XCTFail("Expected not found")
        } catch let error as DenlyError {
            XCTAssertEqual(error, .petNotFound(id))
        } catch {
            XCTFail("Unexpected error")
        }
    }
}
