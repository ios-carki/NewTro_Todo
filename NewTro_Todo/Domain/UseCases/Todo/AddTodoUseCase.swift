import Foundation

protocol AddTodoUseCaseProtocol {
    func execute(text: String, emoji: String, importance: Importance, targetTime: Date?, isAllDay: Bool, reminderOffsetMinutes: Int?, targetDate: Date) async throws -> TodoEntity
}

final class AddTodoUseCase: AddTodoUseCaseProtocol {
    private let repository: TodoRepositoryProtocol

    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(text: String, emoji: String, importance: Importance, targetTime: Date?, isAllDay: Bool, reminderOffsetMinutes: Int?, targetDate: Date) async throws -> TodoEntity {
        return try await repository.addTodo(text: text, emoji: emoji, importance: importance, targetTime: targetTime, isAllDay: isAllDay, reminderOffsetMinutes: reminderOffsetMinutes, targetDate: targetDate)
    }
}
