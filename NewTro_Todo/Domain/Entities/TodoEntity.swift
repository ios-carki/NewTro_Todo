import Foundation

struct TodoEntity: Identifiable {
    let id: String
    var text: String
    var isFavorite: Bool
    var importance: Importance
    var createdAt: Date
    var targetDate: Date
    var isCompleted: Bool
    var targetTimeStart: Date?
    var targetTimeEnd: Date?
    var isAllDay: Bool
    var notifyAt: Date?
    var sortOrder: Int
    var completedAt: Date?
    var colorName: String
    var routineId: String?
}
