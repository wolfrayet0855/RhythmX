//  NotificationScheduler.swift

import UserNotifications
import Foundation

struct NotificationScheduler {

    static func requestPermissionIfNeeded(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(
                    options: [.alert, .sound, .badge]
                ) { granted, _ in
                    DispatchQueue.main.async { completion(granted) }
                }
            case .authorized, .provisional:
                DispatchQueue.main.async { completion(true) }
            default:
                DispatchQueue.main.async { completion(false) }
            }
        }
    }

    static func scheduleCycleReminders(for date: Date, dayBefore: Bool, dayOf: Bool) {
        cancelAllCycleReminders()

        if dayBefore, let dayBeforeDate = Calendar.current.date(byAdding: .day, value: -1, to: date) {
            schedule(
                id: "rhythmx.cycle.daybefore",
                title: "Cycle Reminder",
                body: "Your cycle is anticipated to start tomorrow. Be prepared.",
                date: dayBeforeDate
            )
        }

        if dayOf {
            schedule(
                id: "rhythmx.cycle.dayof",
                title: "Cycle Reminder",
                body: "Menstrual cycle is anticipated to start today.",
                date: date
            )
        }
    }

    static func cancelAllCycleReminders() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [
                "rhythmx.cycle.daybefore",
                "rhythmx.cycle.dayof"
            ])
    }

    private static func schedule(id: String, title: String, body: String, date: Date) {
        guard date > Date() else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = 8
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
