import Foundation

/// Kind of generated insight.
public enum InsightKind: String, Sendable, Hashable {
    case streak
    case slot
    case weekly
    case encouragement
}

/// A short analytics insight for the journal.
public struct Insight: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let kind: InsightKind
    public let title: String
    public let detail: String

    public init(
        id: UUID = UUID(),
        kind: InsightKind,
        title: String,
        detail: String
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.detail = detail
    }
}
