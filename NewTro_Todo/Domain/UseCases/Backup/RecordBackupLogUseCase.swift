import Foundation

protocol RecordBackupLogUseCaseProtocol {
    func execute(counts: BackupCounts) async
}

final class RecordBackupLogUseCase: RecordBackupLogUseCaseProtocol {
    private let repository: any BackupLogRepositoryProtocol

    init(repository: any BackupLogRepositoryProtocol) {
        self.repository = repository
    }

    func execute(counts: BackupCounts) async {
        await repository.append(BackupLogEntry(counts: counts))
    }
}
