import Foundation

protocol EditTodoUseCaseProtocol {
    func execute(
        id: String,
        text: String,
        importance: Importance,
        targetTimeStart: Date?,
        targetTimeEnd: Date?,
        isAllDay: Bool,
        notifyAt: Date?
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
        targetTimeStart: Date?,
        targetTimeEnd: Date?,
        isAllDay: Bool,
        notifyAt: Date?
    ) async throws {
        try await repository.updateTodo(
            id: id,
            text: text,
            importance: importance,
            targetTimeStart: targetTimeStart,
            targetTimeEnd: targetTimeEnd,
            isAllDay: isAllDay,
            notifyAt: notifyAt
        )
    }
}
