import Foundation

protocol LocalNotificationRepositoryProtocol {
    func getAuthorizationStatus() async -> NotificationAuthorizationStatus
    func requestAuthorization() async throws -> Bool
    func scheduleDaily(id: String, titleKey: String, bodyKey: String, hour: Int, minute: Int) async throws
    func cancel(id: String) async
}
