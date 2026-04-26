import Foundation
import Combine
import WidgetKit

@MainActor
final class MainViewModel: ObservableObject {

    // MARK: - State
    @Published var todos: [TodoEntity] = []
    @Published var selectedDate: Date = Date()
    @Published var actionTarget: TodoEntity? = nil
    @Published var postponeTarget: TodoEntity? = nil
    @Published var errorMessage: String? = nil

    var formattedDate: String { DateFormatter.dateToString(date: selectedDate) }
    var completedCount: Int { todos.filter(\.isCompleted).count }
    var heartCount: Int { max(0, 3 - todos.filter { !$0.isCompleted }.count) }

    var worldDate: String {
        let cal = Calendar.current
        let m = cal.component(.month, from: selectedDate)
        let d = cal.component(.day, from: selectedDate)
        return String(format: "%02d-%02d", m, d)
    }

    var displayDate: String {
        let cal = Calendar.current
        let y = cal.component(.year, from: selectedDate)
        let m = cal.component(.month, from: selectedDate)
        let d = cal.component(.day, from: selectedDate)
        return String(format: "%04d.%02d.%02d", y, m, d)
    }

    // MARK: - Use Cases
    private let fetchTodosUseCase: any FetchTodosUseCaseProtocol
    private let addTodoUseCase: any AddTodoUseCaseProtocol
    private let updateTodoTextUseCase: any UpdateTodoTextUseCaseProtocol
    private let toggleCompleteUseCase: any ToggleTodoCompleteUseCaseProtocol
    private let postponeTodoUseCase: any PostponeTodoUseCaseProtocol
    private let updateImportanceUseCase: any UpdateTodoImportanceUseCaseProtocol
    private let toggleFavoriteUseCase: any ToggleTodoFavoriteUseCaseProtocol
    private let deleteTodoUseCase: any DeleteTodoUseCaseProtocol
    private let recordCompleteUseCase: any RecordTodoCompleteUseCaseProtocol
    private let recordTodoAddedUseCase: any RecordTodoAddedUseCaseProtocol
    private let recordPostponeUseCase: any RecordPostponeUseCaseProtocol

    init(
        fetchTodosUseCase: any FetchTodosUseCaseProtocol,
        addTodoUseCase: any AddTodoUseCaseProtocol,
        updateTodoTextUseCase: any UpdateTodoTextUseCaseProtocol,
        toggleCompleteUseCase: any ToggleTodoCompleteUseCaseProtocol,
        postponeTodoUseCase: any PostponeTodoUseCaseProtocol,
        updateImportanceUseCase: any UpdateTodoImportanceUseCaseProtocol,
        toggleFavoriteUseCase: any ToggleTodoFavoriteUseCaseProtocol,
        deleteTodoUseCase: any DeleteTodoUseCaseProtocol,
        recordCompleteUseCase: any RecordTodoCompleteUseCaseProtocol,
        recordTodoAddedUseCase: any RecordTodoAddedUseCaseProtocol,
        recordPostponeUseCase: any RecordPostponeUseCaseProtocol
    ) {
        self.fetchTodosUseCase = fetchTodosUseCase
        self.addTodoUseCase = addTodoUseCase
        self.updateTodoTextUseCase = updateTodoTextUseCase
        self.toggleCompleteUseCase = toggleCompleteUseCase
        self.postponeTodoUseCase = postponeTodoUseCase
        self.updateImportanceUseCase = updateImportanceUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.deleteTodoUseCase = deleteTodoUseCase
        self.recordCompleteUseCase = recordCompleteUseCase
        self.recordTodoAddedUseCase = recordTodoAddedUseCase
        self.recordPostponeUseCase = recordPostponeUseCase
    }

    // MARK: - Date Navigation
    func goYesterday() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
        loadTodos()
    }

    func goTomorrow() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        loadTodos()
    }

    // MARK: - Todo Actions
    func loadTodos() {
        Task {
            do {
                todos = try await fetchTodosUseCase.execute(targetDate: selectedDate)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func addTodo() {
        Task {
            do {
                let newTodo = try await addTodoUseCase.execute(targetDate: selectedDate)
                todos.append(newTodo)
                await recordTodoAddedUseCase.execute()
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func updateText(id: String, text: String) {
        Task {
            do {
                try await updateTodoTextUseCase.execute(id: id, text: text)
                if let idx = todos.firstIndex(where: { $0.id == id }) {
                    todos[idx].text = text
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func toggleComplete(id: String) {
        Task {
            do {
                try await toggleCompleteUseCase.execute(id: id)
                if let idx = todos.firstIndex(where: { $0.id == id }) {
                    todos[idx].isCompleted.toggle()
                    if todos[idx].isCompleted {
                        let wasPostponed = todos[idx].postponeCount > 0
                        let isPerfect = !todos.isEmpty && todos.allSatisfy(\.isCompleted)
                        await recordCompleteUseCase.execute(
                            wasPostponed: wasPostponed,
                            isPerfectDay: isPerfect,
                            date: selectedDate
                        )
                    }
                }
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func postpone(id: String) {
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        postpone(id: id, toDate: nextDay)
    }

    func postpone(id: String, toDate: Date) {
        Task {
            do {
                try await postponeTodoUseCase.execute(id: id, toDate: toDate)
                todos.removeAll { $0.id == id }
                await recordPostponeUseCase.execute()
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func updateImportance(id: String, importance: Importance) {
        Task {
            do {
                try await updateImportanceUseCase.execute(id: id, importance: importance)
                if let idx = todos.firstIndex(where: { $0.id == id }) {
                    todos[idx].importance = importance
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func toggleFavorite(id: String) {
        Task {
            do {
                try await toggleFavoriteUseCase.execute(id: id)
                if let idx = todos.firstIndex(where: { $0.id == id }) {
                    todos[idx].isFavorite.toggle()
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func deleteTodo(id: String) {
        Task {
            do {
                try await deleteTodoUseCase.execute(id: id)
                todos.removeAll { $0.id == id }
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
