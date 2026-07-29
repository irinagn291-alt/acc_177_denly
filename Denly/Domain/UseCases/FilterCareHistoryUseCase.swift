import Foundation

/// Filters care logs by title or date text query.
public struct FilterCareHistoryUseCase: Sendable {
    public init() {}

    public func callAsFunction(
        logs: [CareLog],
        query: String,
        calendar: Calendar = .current
    ) -> [CareLog] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return logs }
        let lowered = trimmed.lowercased()
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return logs.filter { log in
            if log.title.lowercased().contains(lowered) { return true }
            if log.notes.lowercased().contains(lowered) { return true }
            let dateText = formatter.string(from: log.completedAt).lowercased()
            return dateText.contains(lowered)
        }
    }
}
