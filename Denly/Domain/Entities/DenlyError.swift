import Foundation

/// Every failure the domain layer can report.
public enum DenlyError: LocalizedError, Equatable {
    case petNotFound(UUID)
    case routineNotFound(UUID)
    case careLogNotFound(UUID)
    case blankName
    case storeFailure(String)

    public var errorDescription: String? {
        switch self {
        case .petNotFound:
            return "That pet is no longer in the journal."
        case .routineNotFound:
            return "That routine is no longer on the card."
        case .careLogNotFound:
            return "That care entry could not be found."
        case .blankName:
            return "A name is required."
        case .storeFailure(let detail):
            return "The journal could not be saved. \(detail)"
        }
    }
}
