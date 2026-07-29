import Observation
import Foundation

@Observable
@MainActor
public final class RemindersSetupViewModel {
    public var isEnabled: Bool
    public var reminderDate: Date
    public private(set) var statusMessage: String?

    private let store: ReminderPreferencesStore
    private let scheduler: ReminderScheduler

    public init(store: ReminderPreferencesStore, scheduler: ReminderScheduler) {
        self.store = store
        self.scheduler = scheduler
        let loaded = store.load()
        self.isEnabled = loaded.isEnabled
        var components = DateComponents()
        components.hour = loaded.hour
        components.minute = loaded.minute
        self.reminderDate = Calendar.current.date(from: components) ?? Date()
    }

    public func save() async {
        let parts = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
        let preference = ReminderPreference(
            isEnabled: isEnabled,
            hour: parts.hour ?? 20,
            minute: parts.minute ?? 0
        )
        store.save(preference)
        await scheduler.apply(preference)
        statusMessage = isEnabled
            ? "Evening reminder saved for \(String(format: "%02d:%02d", preference.hour, preference.minute))."
            : "Evening reminder turned off."
    }
}
