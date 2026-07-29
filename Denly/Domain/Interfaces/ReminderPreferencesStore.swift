import Foundation

/// Evening reminder preference stored locally.
public struct ReminderPreference: Hashable, Sendable {
    public var isEnabled: Bool
    public var hour: Int
    public var minute: Int

    public init(isEnabled: Bool = false, hour: Int = 20, minute: Int = 0) {
        self.isEnabled = isEnabled
        self.hour = hour
        self.minute = minute
    }

    public var dateComponents: DateComponents {
        DateComponents(hour: hour, minute: minute)
    }
}

public protocol ReminderPreferencesStore: Sendable {
    func load() -> ReminderPreference
    func save(_ preference: ReminderPreference)
}

/// Schedules a local evening reminder when enabled.
public protocol ReminderScheduler: Sendable {
    func apply(_ preference: ReminderPreference) async
}
