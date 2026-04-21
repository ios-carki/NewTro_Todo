import Foundation

struct TodoEntity {
    let id: String
    var text: String
    var isFavorite: Bool
    var importance: Importance
    var createdAt: Date
    var targetDate: Date
    var isCompleted: Bool
}
