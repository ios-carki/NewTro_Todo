import Foundation

protocol RequestNotificationPermissionUseCaseProtocol {
    func execute() async throws -> Bool
}

final class RequestNotificationPermissionUseCase: RequestNotificationPermissionUseCaseProtocol {
    private let repository: any LocalNotificationRepositoryProtocol

    init(repository: any LocalNotificationRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> Bool {
        try await repository.requestAuthorization()
    }
}
