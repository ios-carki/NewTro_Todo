import Foundation
import Combine
import WidgetKit

@MainActor
final class MainViewModel: ObservableObject {

    // MARK: - State
    @Published var todos: [TodoEntity] = []
    @Published var selectedDate: Date = Date()
    @Published var quickNote: QuickNoteEntity? = nil
    @Published var isQuickNotePresented: Bool = false
    @Published var actionTarget: TodoEntity? = nil
    @Published var errorMessage: String? = nil

    var formattedDate: String { DateFormatter.dateToString(date: selectedDate) }

    // MARK: - Use Cases
    private let fetchTodosUseCase: any FetchTodosUseCaseProtocol
    private let addTodoUseCase: any AddTodoUseCaseProtocol
    private let updateTodoTextUseCase: any UpdateTodoTextUseCaseProtocol
    private let toggleCompleteUseCase: any ToggleTodoCompleteUseCaseProtocol
    private let postponeTodoUseCase: any PostponeTodoUseCaseProtocol
    private let updateImportanceUseCase: any UpdateTodoImportanceUseCaseProtocol
    private let toggleFavoriteUseCase: any ToggleTodoFavoriteUseCaseProtocol
    private let deleteTodoUseCase: any DeleteTodoUseCaseProtocol
    private let fetchOrCreateNoteUseCase: any FetchOrCreateQuickNoteUseCaseProtocol
    private let updateNoteUseCase: any UpdateQuickNoteUseCaseProtocol

    init(
        fetchTodosUseCase: any FetchTodosUseCaseProtocol,
        addTodoUseCase: any AddTodoUseCaseProtocol,
        updateTodoTextUseCase: any UpdateTodoTextUseCaseProtocol,
        toggleCompleteUseCase: any ToggleTodoCompleteUseCaseProtocol,
        postponeTodoUseCase: any PostponeTodoUseCaseProtocol,
        updateImportanceUseCase: any UpdateTodoImportanceUseCaseProtocol,
        toggleFavoriteUseCase: any ToggleTodoFavoriteUseCaseProtocol,
        deleteTodoUseCase: any DeleteTodoUseCaseProtocol,
        fetchOrCreateNoteUseCase: any FetchOrCreateQuickNoteUseCaseProtocol,
        updateNoteUseCase: any UpdateQuickNoteUseCaseProtocol
    ) {
        self.fetchTodosUseCase = fetchTodosUseCase
        self.addTodoUseCase = addTodoUseCase
        self.updateTodoTextUseCase = updateTodoTextUseCase
        self.toggleCompleteUseCase = toggleCompleteUseCase
        self.postponeTodoUseCase = postponeTodoUseCase
        self.updateImportanceUseCase = updateImportanceUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.deleteTodoUseCase = deleteTodoUseCase
        self.fetchOrCreateNoteUseCase = fetchOrCreateNoteUseCase
        self.updateNoteUseCase = updateNoteUseCase
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
                }
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func postpone(id: String) {
        Task {
            do {
                let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                try await postponeTodoUseCase.execute(id: id, toDate: nextDay)
                todos.removeAll { $0.id == id }
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

    // MARK: - QuickNote Actions
    func openQuickNote() {
        Task {
            do {
                quickNote = try await fetchOrCreateNoteUseCase.execute(targetDate: selectedDate)
                isQuickNotePresented = true
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func saveQuickNote(text: String) {
        guard let noteId = quickNote?.id else { return }
        Task {
            do {
                try await updateNoteUseCase.execute(id: noteId, note: text)
                quickNote?.note = text
                quickNote?.isWritten = !text.isEmpty
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
