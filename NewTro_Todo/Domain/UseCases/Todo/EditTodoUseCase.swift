import Foundation

protocol EditTodoUseCaseProtocol {
    func execute(id: String, text: String, emoji: String, importance: Importance, targetTime: Date?, isAllDay: Bool, reminderOffsetMinutes: Int?) async throws
}

final class EditTodoUseCase: EditTodoUseCaseProtocol {
    private let repository: TodoRepositoryProtocol

    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: String, text: String, emoji: String, importance: Importance, targetTime: Date?, isAllDay: Bool, reminderOffsetMinutes: Int?) async throws {
        try await repository.updateTodo(id: id, text: text, emoji: emoji, importance: importance, targetTime: targetTime, isAllDay: isAllDay, reminderOffsetMinutes: reminderOffsetMinutes)
    }
}
