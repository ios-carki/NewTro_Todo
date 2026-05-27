import Foundation
import RealmSwift

final class Todo: Object, ObjectKeyIdentifiable {
    @Persisted var todo: String = ""
    @Persisted var favorite: Bool = false
    @Persisted var importance: Int = 0
    @Persisted var regDate: Date = Date()
    @Persisted var stringDate: String = ""
    @Persisted(indexed: true) var targetDate: Date = Date()
    @Persisted var isFinished: Bool = false
    @Persisted var targetTimeStart: Date? = nil
    @Persisted var targetTimeEnd: Date? = nil
    @Persisted var isAllDay: Bool = false
    @Persisted var notifyAt: Date? = nil
    @Persisted var sortOrder: Int = 0
    @Persisted var completedAt: Date? = nil
    @Persisted var colorName: String = "yellow"

    // 루틴이 만든 Todo 만 값을 가짐. 수동 생성 Todo 는 nil.
    @Persisted(indexed: true) var routineId: ObjectId? = nil

    @Persisted(primaryKey: true) var objectID: ObjectId

    convenience init(
        todo: String,
        favorite: Bool,
        importance: Int,
        regDate: Date,
        stringDate: String,
        targetDate: Date,
        isFinished: Bool,
        targetTimeStart: Date? = nil,
        targetTimeEnd: Date? = nil,
        isAllDay: Bool = false,
        notifyAt: Date? = nil,
        sortOrder: Int = 0,
        completedAt: Date? = nil,
        colorName: String = "yellow",
        routineId: ObjectId? = nil
    ) {
        self.init()
        self.todo = todo
        self.favorite = favorite
        self.importance = importance
        self.regDate = regDate
        self.stringDate = stringDate
        self.targetDate = targetDate
        self.isFinished = isFinished
        self.targetTimeStart = targetTimeStart
        self.targetTimeEnd = targetTimeEnd
        self.isAllDay = isAllDay
        self.notifyAt = notifyAt
        self.sortOrder = sortOrder
        self.completedAt = completedAt
        self.colorName = colorName
        self.routineId = routineId
    }
}
