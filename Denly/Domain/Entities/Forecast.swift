import Foundation

/// A projected completion outlook for the coming days.
public struct Forecast: Hashable, Sendable {
    public let projectedRate: Double
    public let focusSlot: RoutineSlot?
    public let summary: String

    public init(projectedRate: Double, focusSlot: RoutineSlot?, summary: String) {
        self.projectedRate = projectedRate
        self.focusSlot = focusSlot
        self.summary = summary
    }
}
