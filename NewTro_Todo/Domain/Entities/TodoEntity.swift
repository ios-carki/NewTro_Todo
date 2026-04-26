import Foundation

struct TodoEntity: Identifiable {
    let id: String
    var text: String
    var isFavorite: Bool
    var importance: Importance
    var createdAt: Date
    var targetDate: Date
    var isCompleted: Bool
    var postponeCount: Int
    var emoji: String
    var dueTime: Date?
}
