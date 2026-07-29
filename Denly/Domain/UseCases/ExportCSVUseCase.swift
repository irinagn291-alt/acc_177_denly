import Foundation

/// Exports care logs as CSV.
public struct ExportCSVUseCase: Sendable {
    private let petRepository: PetRepository
    private let careLogRepository: CareLogRepository

    public init(petRepository: PetRepository, careLogRepository: CareLogRepository) {
        self.petRepository = petRepository
        self.careLogRepository = careLogRepository
    }

    public func callAsFunction() async throws -> String {
        let pets = try await petRepository.fetchAll()
        let petNames = Dictionary(uniqueKeysWithValues: pets.map { ($0.id, $0.name) })
        let logs = try await careLogRepository.fetchAll()
        var lines = ["date,pet,title,notes"]
        let formatter = ISO8601DateFormatter()
        for log in logs.sorted(by: { $0.completedAt > $1.completedAt }) {
            let date = formatter.string(from: log.completedAt)
            let pet = petNames[log.petID] ?? "Unknown"
            let title = csvEscape(log.title)
            let notes = csvEscape(log.notes)
            lines.append("\(date),\(csvEscape(pet)),\(title),\(notes)")
        }
        return lines.joined(separator: "\n") + "\n"
    }

    private func csvEscape(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return value
    }
}
