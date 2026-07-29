import Observation
import SwiftUI

public enum DenlyTab: Hashable, Sendable {
    case today
    case insights
    case pets
}

public enum DenlyRoute: Hashable, Sendable {
    case gallery
    case petDetail(UUID)
    case weeklyRecap
    case streakMilestones
    case routineLibrary
    case remindersSetup
    case historySearch(UUID)
}

public enum DenlySheet: Hashable, Sendable, Identifiable {
    case addRoutine
    case editRoutine(UUID)
    case export
    case addPet
    case fabMenu
    case careNote(petID: UUID, logID: UUID)

    public var id: String {
        switch self {
        case .addRoutine: return "addRoutine"
        case .editRoutine(let id): return "editRoutine-\(id.uuidString)"
        case .export: return "export"
        case .addPet: return "addPet"
        case .fabMenu: return "fabMenu"
        case .careNote(let petID, let logID):
            return "careNote-\(petID.uuidString)-\(logID.uuidString)"
        }
    }
}

@Observable
@MainActor
public final class DenlyCoordinator {
    public var selectedTab: DenlyTab = .today
    public var path: [DenlyRoute] = []
    public var sheet: DenlySheet?

    public init() {}

    public func openGallery() { path.append(.gallery) }
    public func openPet(_ id: UUID) { path.append(.petDetail(id)) }
    public func openWeeklyRecap() { path.append(.weeklyRecap) }
    public func openStreakMilestones() { path.append(.streakMilestones) }
    public func openRoutineLibrary() { path.append(.routineLibrary) }
    public func openRemindersSetup() { path.append(.remindersSetup) }
    public func openHistorySearch(_ petID: UUID) { path.append(.historySearch(petID)) }

    public func presentAddRoutine() { sheet = .addRoutine }
    public func presentEditRoutine(_ id: UUID) { sheet = .editRoutine(id) }
    public func presentExport() { sheet = .export }
    public func presentAddPet() { sheet = .addPet }
    public func presentFabMenu() { sheet = .fabMenu }
    public func presentCareNote(petID: UUID, logID: UUID) { sheet = .careNote(petID: petID, logID: logID) }
    public func dismissSheet() { sheet = nil }
    public func pop() { if !path.isEmpty { path.removeLast() } }
}
