import Foundation

protocol ApplyDailyNotificationsUseCaseProtocol {
    func execute(
        enabled: Bool,
        morning: (hour: Int, minute: Int),
        midnight: (hour: Int, minute: Int)
    ) async throws
}

final class ApplyDailyNotificationsUseCase: ApplyDailyNotificationsUseCaseProtocol {

    static let morningId  = "newtro.daily.morning"
    static let midnightId = "newtro.daily.midnight"

    static let morningTitleKey = "notification.morning.title"
    static let morningBodyKey  = "notification.morning.body"
    static let midnightTitleKey = "notification.midnight.title"
    static let midnightBodyKey  = "notification.midnight.body"

    private let repository: any LocalNotificationRepositoryProtocol

    init(repository: any LocalNotificationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        enabled: Bool,
        morning: (hour: Int, minute: Int),
        midnight: (hour: Int, minute: Int)
    ) async throws {
        await repository.cancel(id: Self.morningId)
        await repository.cancel(id: Self.midnightId)

        guard enabled else { return }

        try await repository.scheduleDaily(
            id: Self.morningId,
            titleKey: Self.morningTitleKey,
            bodyKey: Self.morningBodyKey,
            hour: morning.hour,
            minute: morning.minute
        )
        try await repository.scheduleDaily(
            id: Self.midnightId,
            titleKey: Self.midnightTitleKey,
            bodyKey: Self.midnightBodyKey,
            hour: midnight.hour,
            minute: midnight.minute
        )
    }
}
