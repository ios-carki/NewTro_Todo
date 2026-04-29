import Foundation
import Combine
import SwiftUI
import WidgetKit

@MainActor
final class MainViewModel: ObservableObject {

    // MARK: - State
    @Published var todos: [TodoEntity] = []
    @Published var selectedDate: Date = Date()
    @Published var actionTarget: TodoEntity? = nil
    @Published var postponeTarget: TodoEntity? = nil
    @Published var errorMessage: String? = nil
    @Published var isAddTodoPresented: Bool = false
    @Published var editTarget: TodoEntity? = nil
    @Published var toastMessage: String? = nil
    @Published var isDatePickerPresented: Bool = false
    @Published var templates: [TemplateEntity] = []
    @Published var pendingTemplate: TemplateEntity? = nil

    private var toastTask: Task<Void, Never>?

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
    private let editTodoUseCase: any EditTodoUseCaseProtocol
    private let updateTodoSortOrdersUseCase: any UpdateTodoSortOrdersUseCaseProtocol
    private let fetchTemplatesUseCase: any FetchTemplatesUseCaseProtocol
    private let addTemplateUseCase: any AddTemplateUseCaseProtocol
    private let updateTemplateUseCase: any UpdateTemplateUseCaseProtocol
    private let deleteTemplateUseCase: any DeleteTemplateUseCaseProtocol

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
        recordPostponeUseCase: any RecordPostponeUseCaseProtocol,
        editTodoUseCase: any EditTodoUseCaseProtocol,
        updateTodoSortOrdersUseCase: any UpdateTodoSortOrdersUseCaseProtocol,
        fetchTemplatesUseCase: any FetchTemplatesUseCaseProtocol,
        addTemplateUseCase: any AddTemplateUseCaseProtocol,
        updateTemplateUseCase: any UpdateTemplateUseCaseProtocol,
        deleteTemplateUseCase: any DeleteTemplateUseCaseProtocol
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
        self.editTodoUseCase = editTodoUseCase
        self.updateTodoSortOrdersUseCase = updateTodoSortOrdersUseCase
        self.fetchTemplatesUseCase = fetchTemplatesUseCase
        self.addTemplateUseCase = addTemplateUseCase
        self.updateTemplateUseCase = updateTemplateUseCase
        self.deleteTemplateUseCase = deleteTemplateUseCase
        loadTodos()
    }

    // MARK: - Toast

    func showToast(_ message: String) {
        toastTask?.cancel()
        withAnimation(.easeInOut(duration: 0.3)) { toastMessage = message }
        toastTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.3)) { self.toastMessage = nil }
        }
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
        do {
            todos = try fetchTodosUseCase.execute(targetDate: selectedDate)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func presentAddTodo() {
        isAddTodoPresented = true
    }

    func presentDatePicker() {
        isDatePickerPresented = true
    }

    func navigateToDate(_ date: Date) {
        selectedDate = date
        loadTodos()
    }

    // MARK: - Templates

    func loadTemplates() {
        Task {
            do { templates = try await fetchTemplatesUseCase.execute() }
            catch { errorMessage = error.localizedDescription }
        }
    }

    func saveTemplate(text: String, emoji: String, importance: Importance) {
        Task {
            do {
                _ = try await addTemplateUseCase.execute(text: text, emoji: emoji, importance: importance)
                templates = try await fetchTemplatesUseCase.execute()
                showToast("템플릿 저장 완료")
            } catch { errorMessage = error.localizedDescription }
        }
    }

    func updateTemplate(id: String, text: String, emoji: String, importance: Importance) {
        Task {
            do {
                try await updateTemplateUseCase.execute(id: id, text: text, emoji: emoji, importance: importance)
                templates = try await fetchTemplatesUseCase.execute()
            } catch { errorMessage = error.localizedDescription }
        }
    }

    func deleteTemplate(id: String) {
        Task {
            do {
                try await deleteTemplateUseCase.execute(id: id)
                templates.removeAll { $0.id == id }
            } catch { errorMessage = error.localizedDescription }
        }
    }

    func applyTemplate(_ template: TemplateEntity) {
        pendingTemplate = template
    }

    func presentEditTodo(_ todo: TodoEntity) {
        editTarget = todo
    }

    func editTodo(id: String, text: String, emoji: String, importance: Importance, dueTime: Date?) {
        Task {
            do {
                try await editTodoUseCase.execute(id: id, text: text, emoji: emoji, importance: importance, dueTime: dueTime)
                if let idx = todos.firstIndex(where: { $0.id == id }) {
                    todos[idx].text = text
                    todos[idx].emoji = emoji
                    todos[idx].importance = importance
                    todos[idx].dueTime = dueTime
                }
                // 알림 재설정: 기존 취소 후 새 시간 있으면 등록
                NotificationManager.shared.cancel(todoId: id)
                if let dueTime {
                    NotificationManager.shared.schedule(todoId: id, text: text, emoji: emoji, at: dueTime)
                }
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func addTodo(text: String, emoji: String, importance: Importance, dueTime: Date?) {
        Task {
            do {
                let newTodo = try await addTodoUseCase.execute(
                    text: text, emoji: emoji, importance: importance, dueTime: dueTime, targetDate: selectedDate
                )
                todos.append(newTodo)
                await recordTodoAddedUseCase.execute()
                if let dueTime {
                    NotificationManager.shared.schedule(todoId: newTodo.id, text: text, emoji: emoji, at: dueTime)
                }
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
                    todos[idx].completedAt = todos[idx].isCompleted ? Date() : nil
                    if todos[idx].isCompleted {
                        let wasPostponed = todos[idx].postponeCount > 0
                        let isPerfect = !todos.isEmpty && todos.allSatisfy(\.isCompleted)
                        await recordCompleteUseCase.execute(
                            wasPostponed: wasPostponed,
                            isPerfectDay: isPerfect,
                            date: selectedDate
                        )
                    }
                    todos = Self.sorted(todos)
                }
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func reorderTodos(from source: IndexSet, to destination: Int) {
        var incomplete = todos.filter { !$0.isCompleted }
        let completed = todos.filter { $0.isCompleted }
        incomplete.move(fromOffsets: source, toOffset: destination)
        todos = incomplete + completed

        let updates = incomplete.enumerated().map { (idx, todo) in (id: todo.id, sortOrder: idx) }
        Task {
            do {
                try await updateTodoSortOrdersUseCase.execute(updates: updates)
            } catch {
                errorMessage = error.localizedDescription
                loadTodos()
            }
        }
    }

    private static func sorted(_ input: [TodoEntity]) -> [TodoEntity] {
        input.sorted { a, b in
            if a.isCompleted != b.isCompleted { return !a.isCompleted }
            if !a.isCompleted { return a.sortOrder < b.sortOrder }
            return (a.completedAt ?? .distantPast) < (b.completedAt ?? .distantPast)
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
                NotificationManager.shared.cancel(todoId: id)
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
