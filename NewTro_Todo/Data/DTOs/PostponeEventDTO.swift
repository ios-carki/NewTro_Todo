import Foundation

extension PostponeEventObject {
    func toDomain() -> PostponeEventEntity {
        PostponeEventEntity(
            id: id,
            todoId: todoId,
            eventDate: eventDate,
            ordinalAtTime: ordinalAtTime
        )
    }
}
