import Foundation
import RealmSwift

final class PostponeEventObject: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var todoId: String = ""
    @Persisted var eventDate: Date = Date()
    @Persisted var ordinalAtTime: Int = 0

    convenience init(todoId: String, eventDate: Date, ordinalAtTime: Int) {
        self.init()
        self.id = UUID().uuidString
        self.todoId = todoId
        self.eventDate = eventDate
        self.ordinalAtTime = ordinalAtTime
    }
}
