import Foundation

protocol FetchBackupLogsUseCaseProtocol {
    func execute() async -> [BackupLogEntry]
}

final class FetchBackupLogsUseCase: FetchBackupLogsUseCaseProtocol {
    private let repository: any BackupLogRepositoryProtocol

    init(repository: any BackupLogRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async -> [BackupLogEntry] {
        await repository.fetchAll()
    }
}
