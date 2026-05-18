import Foundation

struct TemplateEntity: Identifiable, Hashable {
    let id: String
    var text: String
    var importance: Importance
    var createdAt: Date
}
