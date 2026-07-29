import Observation
import Foundation

@Observable
@MainActor
public final class InsightsViewModel {
    public private(set) var insights: [Insight] = []
    public private(set) var forecast: Forecast?
    public private(set) var activity: [RoutineActivity] = []
    public private(set) var isLoading = false
    public var errorMessage: String?

    private let buildInsights: BuildInsightsUseCase
    private let buildForecast: BuildForecastUseCase
    private let routineActivity: RoutineActivityUseCase

    public init(
        buildInsights: BuildInsightsUseCase,
        buildForecast: BuildForecastUseCase,
        routineActivity: RoutineActivityUseCase
    ) {
        self.buildInsights = buildInsights
        self.buildForecast = buildForecast
        self.routineActivity = routineActivity
    }

    public func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            insights = try await buildInsights()
            forecast = try await buildForecast()
            activity = try await routineActivity()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public var chartValues: [Double] {
        activity.map { Double($0.count) }
    }

    public var chartLabels: [(Double, String)] {
        activity.enumerated().map { (index, item) in
            (Double(index + 1), String(item.title.prefix(6)))
        }
    }
}
