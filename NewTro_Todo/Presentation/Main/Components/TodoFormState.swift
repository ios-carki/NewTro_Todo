import SwiftUI

// 인라인 패널 ↔ 풀스크린 사이를 오갈 때 입력 상태를 보존하기 위해 둘이 같은 ObservableObject를 바라봄.
// "+ Todo" 진입 시 RootTabContainerView 에서 reset(for: nil), 편집 진입 시 reset(for: todo).
@MainActor
final class TodoFormState: ObservableObject {
    enum DueChip { case today, tomorrow, nextWeek, custom }

    @Published var text: String = ""
    @Published var importance: Importance = .none

    @Published var hasDueDate: Bool = true
    @Published var dueDate: Date = Calendar.current.startOfDay(for: Date())
    @Published var dueChip: DueChip = .today
    @Published var dueCustomOpen: Bool = false

    @Published var hasReminder: Bool = false
    @Published var reminderDate: Date = ReminderDatePickerView.defaultReminderDate()

    @Published var colorName: String = "yellow"

    @Published var editingTodo: TodoEntity? = nil

    var isEditMode: Bool { editingTodo != nil }
    var trimmedText: String { text.trimmingCharacters(in: .whitespaces) }
    var isEmpty: Bool { trimmedText.isEmpty }

    var resolvedTargetTimeStart: Date? {
        hasDueDate ? Calendar.current.startOfDay(for: dueDate) : nil
    }
    var resolvedNotifyAt: Date? {
        hasReminder ? reminderDate : nil
    }

    /// 폼의 기한 입력을 Todo 의 실제 등장 날짜(`targetDate`) 로 변환.
    /// hasDueDate=false 인 경우 호출자가 들고 있는 현재 캘린더 날짜(selectedDate) 를 사용.
    func resolvedTargetDate(fallback: Date) -> Date {
        let cal = Calendar.current
        return hasDueDate
            ? cal.startOfDay(for: dueDate)
            : cal.startOfDay(for: fallback)
    }

    func reset(for todo: TodoEntity?) {
        editingTodo = todo
        text = ""
        importance = .none
        hasDueDate = true
        dueDate = Calendar.current.startOfDay(for: Date())
        dueChip = .today
        dueCustomOpen = false
        hasReminder = false
        reminderDate = ReminderDatePickerView.defaultReminderDate()
        colorName = "yellow"

        guard let todo else { return }
        text = todo.text
        importance = todo.importance
        colorName = todo.colorName

        // 모든 Todo 는 targetDate 를 가진다 — 이를 폼의 dueDate 로 표시.
        hasDueDate = true
        dueDate = Calendar.current.startOfDay(for: todo.targetDate)
        dueChip = Self.detectChip(for: dueDate)

        if let notify = todo.notifyAt {
            hasReminder = true
            reminderDate = notify
        }
    }

    func applyTemplate(_ t: TemplateEntity) {
        text = t.text
        importance = t.importance
    }

    private static func detectChip(for date: Date) -> DueChip {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        if cal.isDate(date, inSameDayAs: today) { return .today }
        if let tom = cal.date(byAdding: .day, value: 1, to: today),
           cal.isDate(date, inSameDayAs: tom) { return .tomorrow }
        if let nw = cal.date(byAdding: .day, value: 7, to: today),
           cal.isDate(date, inSameDayAs: nw) { return .nextWeek }
        return .custom
    }
}
