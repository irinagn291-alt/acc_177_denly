import Foundation

public final class UserDefaultsReminderPreferencesStore: ReminderPreferencesStore, @unchecked Sendable {
    private let defaults: UserDefaults
    private let enabledKey = "denly.reminder.enabled"
    private let hourKey = "denly.reminder.hour"
    private let minuteKey = "denly.reminder.minute"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func load() -> ReminderPreference {
        ReminderPreference(
            isEnabled: defaults.bool(forKey: enabledKey),
            hour: defaults.object(forKey: hourKey) as? Int ?? 20,
            minute: defaults.object(forKey: minuteKey) as? Int ?? 0
        )
    }

    public func save(_ preference: ReminderPreference) {
        defaults.set(preference.isEnabled, forKey: enabledKey)
        defaults.set(preference.hour, forKey: hourKey)
        defaults.set(preference.minute, forKey: minuteKey)
    }
}
