import Foundation

protocol EditTodoUseCaseProtocol {
    func execute(
        id: String,
        text: String,
        importance: Importance,
        targetDate: Date,
        targetTimeStart: Date?,
        targetTimeEnd: Date?,
        isAllDay: Bool,
        notifyAt: Date?,
        colorName: String
    ) async throws
}

final class EditTodoUseCase: EditTodoUseCaseProtocol {
    private let repository: TodoRepositoryProtocol

    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        id: String,
        text: String,
        importance: Importance,
        targetDate: Date,
        targetTimeStart: Date?,
        targetTimeEnd: Date?,
        isAllDay: Bool,
        notifyAt: Date?,
        colorName: String
    ) async throws {
        try await repository.updateTodo(
            id: id,
            text: text,
            importance: importance,
            targetDate: targetDate,
            targetTimeStart: targetTimeStart,
            targetTimeEnd: targetTimeEnd,
            isAllDay: isAllDay,
            notifyAt: notifyAt,
            colorName: colorName
        )
    }
}
