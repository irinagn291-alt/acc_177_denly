import Foundation

/// When in the day a routine belongs.
public enum RoutineSlot: String, CaseIterable, Codable, Sendable, Hashable {
    case morning
    case midday
    case evening

    /// Short label for the slot badge.
    public var badge: String {
        switch self {
        case .morning: return "AM"
        case .midday: return "Mid"
        case .evening: return "PM"
        }
    }

    /// Sort order on the today card.
    public var sortOrder: Int {
        switch self {
        case .morning: return 0
        case .midday: return 1
        case .evening: return 2
        }
    }
}
