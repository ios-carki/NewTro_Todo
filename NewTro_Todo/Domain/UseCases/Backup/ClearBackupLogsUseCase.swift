import Foundation

protocol ClearBackupLogsUseCaseProtocol {
    func execute() async
}

final class ClearBackupLogsUseCase: ClearBackupLogsUseCaseProtocol {
    private let repository: any BackupLogRepositoryProtocol

    init(repository: any BackupLogRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async {
        await repository.clear()
    }
}
