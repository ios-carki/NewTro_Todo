import Foundation
import RealmSwift

final class Todo: Object, ObjectKeyIdentifiable {
    @Persisted var todo: String = ""
    @Persisted var favorite: Bool = false
    @Persisted var importance: Int = 0
    @Persisted var regDate: Date = Date()
    @Persisted var stringDate: String = ""
    @Persisted var targetDate: Date = Date()
    @Persisted var isFinished: Bool = false
    @Persisted var postponeCount: Int = 0
    @Persisted var emoji: String = ""
    @Persisted var dueTime: Date? = nil
    @Persisted var sortOrder: Int = 0
    @Persisted var completedAt: Date? = nil

    @Persisted(primaryKey: true) var objectID: ObjectId

    convenience init(
        todo: String,
        favorite: Bool,
        importance: Int,
        regDate: Date,
        stringDate: String,
        targetDate: Date,
        isFinished: Bool,
        postponeCount: Int = 0,
        emoji: String = "",
        dueTime: Date? = nil,
        sortOrder: Int = 0,
        completedAt: Date? = nil
    ) {
        self.init()
        self.todo = todo
        self.favorite = favorite
        self.importance = importance
        self.regDate = regDate
        self.stringDate = stringDate
        self.targetDate = targetDate
        self.isFinished = isFinished
        self.postponeCount = postponeCount
        self.emoji = emoji
        self.dueTime = dueTime
        self.sortOrder = sortOrder
        self.completedAt = completedAt
    }
}
