import Foundation

// 백업 로그 저장소 — Realm 마이그레이션 회피 위해 UserDefaults에 Codable JSON 저장.
// 최근 maxRetainedLogs 개만 유지하는 FIFO 캡(30) 적용 — UI 노출/저장 모두 동일.
final class BackupLogRepositoryImpl: BackupLogRepositoryProtocol {

    static let maxRetainedLogs = 30

    private let userDefaults: UserDefaults
    private let storageKey = "backup.logs.v1"
    private let queue = DispatchQueue(label: "backup.logs.repo", qos: .utility)

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func append(_ entry: BackupLogEntry) async {
        await withCheckedContinuation { continuation in
            queue.async { [weak self] in
                guard let self else { continuation.resume(); return }
                var list = self.loadSync()
                list.append(entry)
                // createdAt 오름차순으로 정렬 후 앞쪽(오래된) 잘라내기.
                list.sort { $0.createdAt < $1.createdAt }
                let cap = Self.maxRetainedLogs
                if list.count > cap {
                    list = Array(list.suffix(cap))
                }
                self.saveSync(list)
                continuation.resume()
            }
        }
    }

    func fetchAll() async -> [BackupLogEntry] {
        await withCheckedContinuation { continuation in
            queue.async { [weak self] in
                continuation.resume(returning: self?.loadSync() ?? [])
            }
        }
    }

    func clear() async {
        await withCheckedContinuation { continuation in
            queue.async { [weak self] in
                self?.userDefaults.removeObject(forKey: self?.storageKey ?? "")
                continuation.resume()
            }
        }
    }

    // overwrite: 들어온 목록으로 전체 교체. merge: id 기준 합집합 후 최신 30개로 cap.
    func restoreSnapshot(_ entries: [BackupLogEntry], mode: RestoreMode) async {
        await withCheckedContinuation { continuation in
            queue.async { [weak self] in
                guard let self else { continuation.resume(); return }
                var merged: [BackupLogEntry]
                switch mode {
                case .overwrite:
                    merged = entries
                case .merge:
                    let existing = self.loadSync()
                    var seen = Set(existing.map { $0.id })
                    merged = existing
                    for e in entries where seen.insert(e.id).inserted {
                        merged.append(e)
                    }
                }
                merged.sort { $0.createdAt < $1.createdAt }
                let cap = Self.maxRetainedLogs
                if merged.count > cap {
                    merged = Array(merged.suffix(cap))
                }
                self.saveSync(merged)
                continuation.resume()
            }
        }
    }

    private func loadSync() -> [BackupLogEntry] {
        guard let data = userDefaults.data(forKey: storageKey) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([BackupLogEntry].self, from: data)) ?? []
    }

    private func saveSync(_ list: [BackupLogEntry]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(list) else { return }
        userDefaults.set(data, forKey: storageKey)
    }
}
