import Foundation
import UserNotifications

final class LocalNotificationRepositoryImpl: LocalNotificationRepositoryProtocol {

    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func getAuthorizationStatus() async -> NotificationAuthorizationStatus {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .authorized, .provisional, .ephemeral:
            return .authorized
        case .denied:
            return .denied
        @unknown default:
            return .denied
        }
    }

    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .badge, .sound])
    }

    func scheduleDaily(id: String, titleKey: String, bodyKey: String, hour: Int, minute: Int) async throws {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString(titleKey, comment: "")
        content.body  = NSLocalizedString(bodyKey, comment: "")
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try await center.add(request)
    }

    func cancel(id: String) async {
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
}
