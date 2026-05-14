import Foundation

protocol RestoreBackupUseCaseProtocol {
    func execute(from url: URL, mode: RestoreMode) async throws
}

final class RestoreBackupUseCase: RestoreBackupUseCaseProtocol {
    private let repository: any BackupRepositoryProtocol

    init(repository: any BackupRepositoryProtocol) {
        self.repository = repository
    }

    func execute(from url: URL, mode: RestoreMode) async throws {
        try await repository.restoreBackup(from: url, mode: mode)
    }
}
