import Foundation

/// One day cell in the weekly completion heatmap.
public struct HeatmapDay: Identifiable, Hashable, Sendable {
    public var id: Date { day }
    public let day: Date
    public let rate: Double

    public init(day: Date, rate: Double) {
        self.day = day
        self.rate = min(max(rate, 0), 1)
    }
}

/// Weekly care recap: average, best day, and heatmap.
public struct WeeklyRecap: Hashable, Sendable {
    public let averageRate: Double
    public let bestWeekday: Int?
    public let bestWeekdayName: String?
    public let heatmap: [HeatmapDay]
    public let stampedDays: Int

    public init(
        averageRate: Double,
        bestWeekday: Int?,
        bestWeekdayName: String?,
        heatmap: [HeatmapDay],
        stampedDays: Int
    ) {
        self.averageRate = averageRate
        self.bestWeekday = bestWeekday
        self.bestWeekdayName = bestWeekdayName
        self.heatmap = heatmap
        self.stampedDays = stampedDays
    }
}
