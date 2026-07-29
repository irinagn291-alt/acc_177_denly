import Observation
import Foundation

@Observable
@MainActor
public final class WeeklyRecapViewModel {
    public private(set) var recap: WeeklyRecap?
    public private(set) var isLoading = false
    public var errorMessage: String?

    private let buildRecap: BuildWeeklyRecapUseCase

    public init(buildRecap: BuildWeeklyRecapUseCase) {
        self.buildRecap = buildRecap
    }

    public func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            recap = try await buildRecap()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
