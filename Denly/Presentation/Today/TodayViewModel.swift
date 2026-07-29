import Observation
import Foundation

@Observable
@MainActor
public final class TodayViewModel {
    public private(set) var checklist: TodayChecklist?
    public private(set) var isLoading = false
    public var errorMessage: String?

    private let loadToday: LoadTodayChecklistUseCase
    private let logCare: LogCareForDateUseCase
    private let deleteCareLog: DeleteCareLogUseCase

    public init(
        loadToday: LoadTodayChecklistUseCase,
        logCare: LogCareForDateUseCase,
        deleteCareLog: DeleteCareLogUseCase
    ) {
        self.loadToday = loadToday
        self.logCare = logCare
        self.deleteCareLog = deleteCareLog
    }

    public func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            checklist = try await loadToday()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func toggleComplete(row: TodayRow) async {
        do {
            if row.isCompleted, let logID = row.logID {
                try await deleteCareLog(id: logID)
            } else {
                _ = try await logCare(routineID: row.routine.id, on: Date())
            }
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
