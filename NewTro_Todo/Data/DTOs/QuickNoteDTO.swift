import Foundation

extension QuickNote {
    func toDomain() -> QuickNoteEntity {
        QuickNoteEntity(
            id: objectID.stringValue,
            note: note,
            createdAt: regDate,
            targetDate: targetDate,
            isWritten: isWrited
        )
    }
}
