import Foundation

struct PostponeEventEntity: Identifiable {
    let id: String
    let todoId: String
    let eventDate: Date
    let ordinalAtTime: Int
}
