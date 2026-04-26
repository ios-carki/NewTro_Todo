import Foundation

enum MemoFilter: Equatable {
    case all
    case today
    case days(Int)
    case range(from: Date, to: Date)

    static func == (lhs: MemoFilter, rhs: MemoFilter) -> Bool {
        switch (lhs, rhs) {
        case (.all, .all), (.today, .today): return true
        case (.days(let a), .days(let b)): return a == b
        case (.range, .range): return true
        default: return false
        }
    }
}

protocol MemoRepositoryProtocol {
    func fetchAll() async throws -> [MemoEntity]
    func fetchMemos(from: Date, to: Date) async throws -> [MemoEntity]
    func addMemo(colorName: String) async throws -> MemoEntity
    func updateMemo(id: String, note: String, colorName: String) async throws
    func deleteMemo(id: String) async throws
    func deleteAll() async throws
}
