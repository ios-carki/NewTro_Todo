import Foundation
import Combine
import SwiftUI
import WidgetKit

struct DayPreviewStats: Equatable {
    let totalTodos: Int
    let completedTodos: Int
    let memoCount: Int

    var incompleteTodos: Int { max(0, totalTodos - completedTodos) }
}

enum MainActiveSheet: Identifiable {
    case addTodo
    case editTodo(TodoEntity)
    case actionMenu(TodoEntity)
    case postpone(TodoEntity)
    case datePicker

    var id: String {
        switch self {
        case .addTodo:           return "addTodo"
        case .editTodo(let t):   return "editTodo_\(t.id)"
        case .actionMenu(let t): return "actionMenu_\(t.id)"
        case .postpone(let t):   return "postpone_\(t.id)"
        case .datePicker:        return "datePicker"
        }
    }
}

@MainActor
final class MainViewModel: ObservableObject {

    // MARK: - State
    @Published var todos: [TodoEntity] = []
    @Published var selectedDate: Date = Date()
    @Published var activeSheet: MainActiveSheet? = nil
    @Published var errorMessage: String? = nil
    @Published var toastMessage: String? = nil
    @Published var templates: [TemplateEntity] = []
    @Published var pendingTemplate: TemplateEntity? = nil
    @Published var actionMenuRecentlyDismissed: Bool = false
    @Published private(set) var dayMemos: [MemoEntity] = []
    @Published private(set) var dayPostponeEvents: [PostponeEventEntity] = []

    private var toastTask: Task<Void, Never>?
    private var actionMenuDismissTask: Task<Void, Never>?

    var formattedDate: String { DateFormatter.dateToString(date: selectedDate) }
    var completedCount: Int { todos.filter(\.isCompleted).count }

    /// HUD 동전 — 그 날 번 동전 (완료 Todo 가중치 + 작성된 메모 수)
    var dayCoinCount: Int {
        let todoCoins = todos.filter(\.isCompleted)
            .map(\.importance.coinValue)
            .reduce(0, +)
        let memoCoins = dayMemos.filter(\.isWritten).count
        return todoCoins + memoCoins
    }

    /// HUD 하트 — 그 날 작성수 - 미루기 누적 페널티(회차당 1/2/3 캡)
    var heartCount: Int {
        let writeCount = todos.count
        let penalty = dayPostponeEvents
            .map { min($0.ordinalAtTime, 3) }
            .reduce(0, +)
        return max(0, writeCount - penalty)
    }

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

    /// 오늘보다 이전 날짜를 보고 있으면 true
    /// → 완료 토글/미루기/편집은 잠그고, 삭제만 허용
    var isViewingPastDate: Bool {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let viewing = cal.startOfDay(for: selectedDate)
        return viewing < today
    }

    // MARK: - Use Cases
    private let fetchTodosUseCase: any FetchTodosUseCaseProtocol
    private let fetchMemosUseCase: any FetchMemosUseCaseProtocol
    private let fetchMonthOverviewUseCase: any FetchMonthOverviewUseCaseProtocol
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
    private let earnCoinsUseCase: any EarnCoinsUseCaseProtocol
    private let recordPostponeEventUseCase: any RecordPostponeEventUseCaseProtocol
    private let fetchPostponeEventsForDateUseCase: any FetchPostponeEventsForDateUseCaseProtocol

    init(
        fetchTodosUseCase: any FetchTodosUseCaseProtocol,
        fetchMemosUseCase: any FetchMemosUseCaseProtocol,
        fetchMonthOverviewUseCase: any FetchMonthOverviewUseCaseProtocol,
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
        deleteTemplateUseCase: any DeleteTemplateUseCaseProtocol,
        earnCoinsUseCase: any EarnCoinsUseCaseProtocol,
        recordPostponeEventUseCase: any RecordPostponeEventUseCaseProtocol,
        fetchPostponeEventsForDateUseCase: any FetchPostponeEventsForDateUseCaseProtocol
    ) {
        self.fetchTodosUseCase = fetchTodosUseCase
        self.fetchMemosUseCase = fetchMemosUseCase
        self.fetchMonthOverviewUseCase = fetchMonthOverviewUseCase
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
        self.earnCoinsUseCase = earnCoinsUseCase
        self.recordPostponeEventUseCase = recordPostponeEventUseCase
        self.fetchPostponeEventsForDateUseCase = fetchPostponeEventsForDateUseCase
        loadTodos()
    }

    // MARK: - Action Menu Dismiss Guard

    func onActionMenuDismissed() {
        actionMenuDismissTask?.cancel()
        actionMenuRecentlyDismissed = true
        actionMenuDismissTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            actionMenuRecentlyDismissed = false
        }
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
        Task { await loadDayMetrics() }
    }

    /// HUD 동전·하트 계산용 일일 데이터 (메모, 미루기 이벤트) 로드
    private func loadDayMetrics() async {
        let cal = Calendar.current
        let start = cal.startOfDay(for: selectedDate)
        let end = cal.date(byAdding: .day, value: 1, to: start) ?? start
        dayMemos = (try? await fetchMemosUseCase.execute(filter: .range(from: start, to: end))) ?? []
        dayPostponeEvents = (try? await fetchPostponeEventsForDateUseCase.execute(date: selectedDate)) ?? []
    }

    func presentAddTodo() {
        activeSheet = .addTodo
    }

    func presentDatePicker() {
        activeSheet = .datePicker
    }

    func navigateToDate(_ date: Date) {
        selectedDate = date
        loadTodos()
    }

    // MARK: - Date Picker Sheet 보조 조회
    func fetchMonthOverview(year: Int, month: Int) async -> [Int: DayContent] {
        do {
            let overview = try await fetchMonthOverviewUseCase.execute(year: year, month: month)
            return overview.dayContent
        } catch {
            return [:]
        }
    }

    func fetchDayPreviewStats(for date: Date) async -> DayPreviewStats {
        let todos: [TodoEntity] = (try? fetchTodosUseCase.execute(targetDate: date)) ?? []
        let cal = Calendar.current
        let start = cal.startOfDay(for: date)
        let end = cal.date(byAdding: .day, value: 1, to: start) ?? start
        let memos: [MemoEntity] = (try? await fetchMemosUseCase.execute(filter: .range(from: start, to: end))) ?? []
        return DayPreviewStats(
            totalTodos: todos.count,
            completedTodos: todos.filter(\.isCompleted).count,
            memoCount: memos.count
        )
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
        activeSheet = .editTodo(todo)
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
                        try? await earnCoinsUseCase.execute(reason: .todoCompleted(
                            importance: todos[idx].importance
                        ))
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
                let oldOrdinal = todos.first(where: { $0.id == id })?.postponeCount ?? 0
                let eventDate = Calendar.current.startOfDay(for: selectedDate)
                try await postponeTodoUseCase.execute(id: id, toDate: toDate)
                todos.removeAll { $0.id == id }
                await recordPostponeUseCase.execute()
                try? await recordPostponeEventUseCase.execute(
                    todoId: id,
                    eventDate: eventDate,
                    ordinalAtTime: oldOrdinal + 1
                )
                await loadDayMetrics()
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
