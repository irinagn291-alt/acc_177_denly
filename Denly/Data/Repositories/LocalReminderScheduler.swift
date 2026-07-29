import Foundation
import UserNotifications

/// Schedules a repeating local evening care reminder.
public final class LocalReminderScheduler: ReminderScheduler, @unchecked Sendable {
    public static let identifier = "denly.evening.care"

    private let center: UNUserNotificationCenter

    public init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    public func apply(_ preference: ReminderPreference) async {
        center.removePendingNotificationRequests(withIdentifiers: [Self.identifier])
        guard preference.isEnabled else { return }

        let granted: Bool
        do {
            granted = try await center.requestAuthorization(options: [.alert, .sound])
        } catch {
            return
        }
        guard granted else { return }

        let content = UNMutableNotificationContent()
        content.title = "Denly"
        content.body = "Evening care — stamp tonight's routines."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: preference.dateComponents,
            repeats: true
        )
        let request = UNNotificationRequest(
            identifier: Self.identifier,
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
    }
}
