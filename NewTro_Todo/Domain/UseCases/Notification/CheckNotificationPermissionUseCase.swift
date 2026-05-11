import Foundation

protocol CheckNotificationPermissionUseCaseProtocol {
    func execute() async -> NotificationAuthorizationStatus
}

final class CheckNotificationPermissionUseCase: CheckNotificationPermissionUseCaseProtocol {
    private let repository: any LocalNotificationRepositoryProtocol

    init(repository: any LocalNotificationRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async -> NotificationAuthorizationStatus {
        await repository.getAuthorizationStatus()
    }
}
