import Foundation
import RealmSwift

final class Todo: Object, ObjectKeyIdentifiable {
    @Persisted var todo: String = ""
    @Persisted var favorite: Bool = false
    @Persisted var importance: Int = 0
    @Persisted var regDate: Date = Date()
    @Persisted var stringDate: String = ""
    @Persisted var isFinished: Bool = false

    @Persisted(primaryKey: true) var objectID: ObjectId

    convenience init(
        todo: String,
        favorite: Bool,
        importance: Int,
        regDate: Date,
        stringDate: String,
        isFinished: Bool
    ) {
        self.init()
        self.todo = todo
        self.favorite = favorite
        self.importance = importance
        self.regDate = regDate
        self.stringDate = stringDate
        self.isFinished = isFinished
    }
}
