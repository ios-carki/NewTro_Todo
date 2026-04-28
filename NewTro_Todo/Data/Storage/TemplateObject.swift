import Foundation
import RealmSwift

final class TemplateObject: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var text: String = ""
    @Persisted var emoji: String = ""
    @Persisted var importance: Int = 0
    @Persisted var createdAt: Date = Date()
}
