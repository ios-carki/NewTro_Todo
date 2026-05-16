import Foundation

protocol AddTodoUseCaseProtocol {
    func execute(
        text: String,
        emoji: String,
        importance: Importance,
        targetDate: Date,
        targetTimeStart: Date?,
        targetTimeEnd: Date?,
        isAllDay: Bool,
        notifyAt: Date?
    ) async throws -> TodoEntity
}

final class AddTodoUseCase: AddTodoUseCaseProtocol {
    private let repository: TodoRepositoryProtocol

    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        text: String,
        emoji: String,
        importance: Importance,
        targetDate: Date,
        targetTimeStart: Date?,
        targetTimeEnd: Date?,
        isAllDay: Bool,
        notifyAt: Date?
    ) async throws -> TodoEntity {
        return try await repository.addTodo(
            text: text,
            emoji: emoji,
            importance: importance,
            targetDate: targetDate,
            targetTimeStart: targetTimeStart,
            targetTimeEnd: targetTimeEnd,
            isAllDay: isAllDay,
            notifyAt: notifyAt
        )
    }
}
