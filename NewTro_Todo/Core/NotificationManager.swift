import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func schedule(todoId: String, text: String, emoji: String, at date: Date) {
        let content = UNMutableNotificationContent()
        let prefix = emoji.isEmpty ? "" : "\(emoji) "
        content.title = "할 일 알림".localized()
        content.body = prefix + text
        content.sound = .default

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(identifier: "todo_\(todoId)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func cancel(todoId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["todo_\(todoId)"])
    }
}
