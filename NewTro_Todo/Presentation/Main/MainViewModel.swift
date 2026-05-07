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

enum TodoSection: String, CaseIterable {
    case favorites
    case todo
    case done
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
    @Published private var collapsedByDate: [String: Set<String>] = [:]

    private var toastTask: Task<Void, Never>?
    private var actionMenuDismissTask: Task<Void, Never>?

    // 섹션 접기 상태 영속화 (UserDefaults — 화면 선호도이므로 Realm 마이그레이션 회피)
    private static let collapsedDefaultsKey = "sectionCollapsedByDate.v1"
    private static let dateKeyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = .current
        return f
    }()

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
    /// writeCount는 "그 날 한때라도 stringDate가 selectedDate였던 todo 개수":
    ///   현재 보이는 todos.count + 그 날 미루기로 떠난 이벤트 수
    /// (이렇게 안 하면 미루기 시 writeCount −1 + 페널티 −1 = 하트 −2 잘못 깎임)
    var heartCount: Int {
        let writeCount = todos.count + dayPostponeEvents.count
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
        loadCollapsedFromDefaults()
        loadTodos()
    }

    // MARK: - Section Collapse

    func isCollapsed(_ section: TodoSection) -> Bool {
        collapsedByDate[Self.dateKeyFormatter.string(from: selectedDate)]?.contains(section.rawValue) ?? false
    }

    func toggleCollapse(_ section: TodoSection) {
        let key = Self.dateKeyFormatter.string(from: selectedDate)
        var set = collapsedByDate[key] ?? []
        if set.contains(section.rawValue) {
            set.remove(section.rawValue)
        } else {
            set.insert(section.rawValue)
        }
        if set.isEmpty {
            collapsedByDate.removeValue(forKey: key)
        } else {
            collapsedByDate[key] = set
        }
        persistCollapsed()
    }

    private func loadCollapsedFromDefaults() {
        guard let data = UserDefaults.standard.data(forKey: Self.collapsedDefaultsKey),
              let raw = try? JSONDecoder().decode([String: [String]].self, from: data) else {
            return
        }
        // 90일 지난 항목 정리 (무한 누적 방지)
        let cutoff = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
        var pruned: [String: Set<String>] = [:]
        for (keyStr, vals) in raw {
            guard let date = Self.dateKeyFormatter.date(from: keyStr), date >= cutoff else { continue }
            pruned[keyStr] = Set(vals)
        }
        collapsedByDate = pruned
        if pruned.count != raw.count { persistCollapsed() }
    }

    private func persistCollapsed() {
        let raw = collapsedByDate.mapValues { Array($0) }
        if let data = try? JSONEncoder().encode(raw) {
            UserDefaults.standard.set(data, forKey: Self.collapsedDefaultsKey)
        }
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
    /// 메모 쿼리: FetchMemosUseCase의 `.range`가 from/to에 startOfDay·+1일 정규화를 자동 적용하므로
    /// 같은 날짜를 양쪽에 넘긴다(같은 날 boundary 보정 → [start, start+1) 1일 윈도우).
    private func loadDayMetrics() async {
        dayMemos = (try? await fetchMemosUseCase.execute(filter: .range(from: selectedDate, to: selectedDate))) ?? []
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
        // FetchMemosUseCase의 .range는 to에 +1일 정규화를 적용하므로 같은 날짜를 양쪽에 넘긴다.
        let memos: [MemoEntity] = (try? await fetchMemosUseCase.execute(filter: .range(from: date, to: date))) ?? []
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

    /// 즐겨찾기 그룹 내에서만 순서 재배치
    func reorderFavorites(from source: IndexSet, to destination: Int) {
        var favorites = todos.filter { !$0.isCompleted && $0.isFavorite }
        favorites.move(fromOffsets: source, toOffset: destination)
        applyIncompleteReorder(favorites: favorites, nonFavorites: nil)
    }

    /// 일반(즐겨찾기 아님) 그룹 내에서만 순서 재배치
    func reorderNonFavorites(from source: IndexSet, to destination: Int) {
        var nonFavorites = todos.filter { !$0.isCompleted && !$0.isFavorite }
        nonFavorites.move(fromOffsets: source, toOffset: destination)
        applyIncompleteReorder(favorites: nil, nonFavorites: nonFavorites)
    }

    /// 한쪽 그룹의 새 배열을 받아 todos 전체 순서 + sortOrder 영속화
    private func applyIncompleteReorder(favorites: [TodoEntity]?, nonFavorites: [TodoEntity]?) {
        let favs = favorites ?? todos.filter { !$0.isCompleted && $0.isFavorite }
        let nonFavs = nonFavorites ?? todos.filter { !$0.isCompleted && !$0.isFavorite }
        let completed = todos.filter { $0.isCompleted }
        todos = favs + nonFavs + completed

        let combined = favs + nonFavs
        let updates = combined.enumerated().map { (idx, todo) in (id: todo.id, sortOrder: idx) }
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
            if !a.isCompleted {
                if a.isFavorite != b.isFavorite { return a.isFavorite }
                return a.sortOrder < b.sortOrder
            }
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
                    todos = Self.sorted(todos)
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
