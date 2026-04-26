import Foundation

struct MemoEntity: Identifiable {
    let id: String
    var note: String
    var targetDate: Date
    var colorName: String
    var isWritten: Bool
    var createdAt: Date
}
