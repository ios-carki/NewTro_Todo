import Foundation

protocol RestoreBackupUseCaseProtocol {
    func execute(from url: URL, mode: RestoreMode) async throws
}

final class RestoreBackupUseCase: RestoreBackupUseCaseProtocol {
    private let repository: any BackupRepositoryProtocol
    private let materializeUseCase: any MaterializeRoutinesUseCaseProtocol

    init(repository: any BackupRepositoryProtocol,
         materializeUseCase: any MaterializeRoutinesUseCaseProtocol) {
        self.repository = repository
        self.materializeUseCase = materializeUseCase
    }

    func execute(from url: URL, mode: RestoreMode) async throws {
        try await repository.restoreBackup(from: url, mode: mode)
        // 복구로 들어온 루틴 규칙 기준으로 미래 루틴 Todo 를 재생성한다(미래분은 백업에서 제외됨).
        // materialize 는 (routineId, targetDate) 로 idempotent → 복구된 과거·오늘 분과 중복되지 않음.
        // reset() 으로 in-memory 커서를 무효화해 복구 직후에도 다시 풀스캔하도록 한다.
        await MainActor.run {
            materializeUseCase.reset()
            try? materializeUseCase.execute()
        }
    }
}
