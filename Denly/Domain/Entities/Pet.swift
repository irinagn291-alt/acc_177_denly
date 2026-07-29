import Foundation

/// A pet in the care journal.
public struct Pet: Identifiable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    public var species: String
    public var createdAt: Date
    /// Relative path under Documents for an optional local avatar image.
    public var avatarRelativePath: String?

    public init(
        id: UUID = UUID(),
        name: String,
        species: String = "",
        createdAt: Date = Date(),
        avatarRelativePath: String? = nil
    ) {
        self.id = id
        self.name = name
        self.species = species
        self.createdAt = createdAt
        self.avatarRelativePath = avatarRelativePath
    }
}
