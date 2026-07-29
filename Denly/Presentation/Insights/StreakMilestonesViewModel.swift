import Observation
import Foundation

@Observable
@MainActor
public final class StreakMilestonesViewModel {
    public private(set) var progress: StreakMilestoneProgress?
    public private(set) var isLoading = false
    public var errorMessage: String?

    private let loadMilestones: LoadStreakMilestonesUseCase

    public init(loadMilestones: LoadStreakMilestonesUseCase) {
        self.loadMilestones = loadMilestones
    }

    public func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            progress = try await loadMilestones()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
