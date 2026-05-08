import Foundation
import RealmSwift

final class QuickNote: Object {
    @Persisted var note: String = ""
    @Persisted var regDate: Date = Date()
    @Persisted var stringToRegDate: String = ""
    @Persisted var targetDate: Date = Date()
    @Persisted var isWrited: Bool = false
    @Persisted var colorName: String = ""

    @Persisted(primaryKey: true) var objectID: ObjectId

    convenience init(
        note: String,
        regDate: Date,
        stringToRegDate: String,
        targetDate: Date,
        isWrited: Bool,
        colorName: String = ""
    ) {
        self.init()
        self.note = note
        self.regDate = regDate
        self.stringToRegDate = stringToRegDate
        self.targetDate = targetDate
        self.isWrited = isWrited
        self.colorName = colorName
    }
}
