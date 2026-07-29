import Foundation

/// Attaches or updates a quick note on an existing care log.
public struct UpdateCareNoteUseCase: Sendable {
    private let repository: CareLogRepository

    public init(repository: CareLogRepository) {
        self.repository = repository
    }

    public func callAsFunction(logID: UUID, note: String) async throws -> CareLog {
        guard var log = try await repository.fetch(id: logID) else {
            throw DenlyError.careLogNotFound(logID)
        }
        log.notes = note.trimmingCharacters(in: .whitespacesAndNewlines)
        try await repository.save(log)
        return log
    }
}
