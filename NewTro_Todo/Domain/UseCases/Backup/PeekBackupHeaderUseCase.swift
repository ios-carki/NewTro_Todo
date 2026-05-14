import Foundation

protocol PeekBackupHeaderUseCaseProtocol {
    func execute(at url: URL) async throws -> BackupHeader
}

final class PeekBackupHeaderUseCase: PeekBackupHeaderUseCaseProtocol {
    private let repository: any BackupRepositoryProtocol

    init(repository: any BackupRepositoryProtocol) {
        self.repository = repository
    }

    func execute(at url: URL) async throws -> BackupHeader {
        try await repository.peekHeader(at: url)
    }
}
