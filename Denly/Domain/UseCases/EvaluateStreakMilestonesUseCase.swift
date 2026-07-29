import Foundation

/// Pure evaluation of which streak milestones are reached.
public struct EvaluateStreakMilestonesUseCase: Sendable {
    public init() {}

    public func callAsFunction(currentStreak: Int) -> StreakMilestoneProgress {
        let reached = StreakMilestone.allCases.filter { currentStreak >= $0.rawValue }
        let next = StreakMilestone.allCases.first { currentStreak < $0.rawValue }
        return StreakMilestoneProgress(
            currentStreak: max(currentStreak, 0),
            reached: reached,
            next: next
        )
    }
}

/// Loads streak then evaluates milestones.
public struct LoadStreakMilestonesUseCase: Sendable {
    private let computeStreak: ComputeStreakUseCase
    private let evaluate: EvaluateStreakMilestonesUseCase

    public init(
        computeStreak: ComputeStreakUseCase,
        evaluate: EvaluateStreakMilestonesUseCase = EvaluateStreakMilestonesUseCase()
    ) {
        self.computeStreak = computeStreak
        self.evaluate = evaluate
    }

    public func callAsFunction(
        petID: UUID? = nil,
        referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) async throws -> StreakMilestoneProgress {
        let rail = try await computeStreak(
            petID: petID,
            referenceDate: referenceDate,
            calendar: calendar
        )
        return evaluate(currentStreak: rail.currentStreak)
    }
}
