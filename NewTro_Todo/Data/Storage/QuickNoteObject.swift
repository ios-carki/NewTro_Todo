import Foundation
import RealmSwift

final class QuickNote: Object {
    @Persisted var note: String = ""
    @Persisted var regDate: Date = Date()
    @Persisted var stringToRegDate: String = ""
    @Persisted var isWrited: Bool = false
    @Persisted var colorName: String = ""

    @Persisted(primaryKey: true) var objectID: ObjectId

    convenience init(
        note: String,
        regDate: Date,
        stringToRegDate: String,
        isWrited: Bool,
        colorName: String = ""
    ) {
        self.init()
        self.note = note
        self.regDate = regDate
        self.stringToRegDate = stringToRegDate
        self.isWrited = isWrited
        self.colorName = colorName
    }
}
