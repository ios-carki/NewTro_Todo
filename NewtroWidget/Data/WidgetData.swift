import Foundation
import SwiftUI
import RealmSwift

// MARK: - Widget Data Models

struct WidgetTodoItem: Identifiable, Hashable {
    let id: String
    let text: String
    let importance: Int   // 0=none, 1=high, 2=medium
    let done: Bool

    var priorityColor: Color {
        switch importance {
        case 1:  return .pixelRed   // high
        case 2:  return .sun        // medium
        default: return .grass      // none
        }
    }
}

struct WidgetMemoItem: Identifiable, Hashable {
    let id: String
    let text: String
    let colorName: String

    /// 메모 색상 — 앱 MemoColorPalette 와 동일 값(위젯 타깃이 분리돼 있어 복제).
    var color: Color {
        switch colorName {
        case "pink":     return Color(hex: "#F8BBD9")
        case "mint":     return Color(hex: "#B2DFDB")
        case "lavender": return Color(hex: "#E1BEE7")
        case "peach":    return Color(hex: "#FFCCBC")
        case "sky":      return Color(hex: "#B3E5FC")
        default:         return Color(hex: "#FFF59D")  // yellow
        }
    }
}

/// 달력 한 칸의 요약 — 그 날의 Todo 개수/완료수 + 메모 유무.
struct WidgetDayCell: Hashable {
    var todoCount: Int = 0
    var doneCount: Int = 0
    var hasMemo: Bool = false

    /// Todo 가 있고 전부 완료된 날(노란색 배경 조건).
    var allDone: Bool { todoCount > 0 && doneCount == todoCount }
}

// MARK: - Today Widget Data (Small 플립달력 / Medium 투두리스트 / Large 달력 공용)

struct TodayWidgetData {
    let date: Date                         // 오늘(startOfDay)
    let todayTodoCount: Int                // 오늘 전체 Todo 개수 (Small 하단)
    let todos: [WidgetTodoItem]            // 오늘 Todo 목록 (Medium)
    let monthCells: [Int: WidgetDayCell]   // 이번 달 day → 요약 (Large 달력)

    var year: Int  { Calendar.current.component(.year,  from: date) }
    var month: Int { Calendar.current.component(.month, from: date) }
    var day: Int   { Calendar.current.component(.day,   from: date) }

    static func empty(_ date: Date = Date()) -> TodayWidgetData {
        TodayWidgetData(date: Calendar.current.startOfDay(for: date),
                        todayTodoCount: 0, todos: [], monthCells: [:])
    }

    static let placeholder = TodayWidgetData(
        date: Calendar.current.startOfDay(for: Date()),
        todayTodoCount: 3,
        todos: [
            .init(id: "1", text: NSLocalizedString("운동 30분", comment: ""),   importance: 1, done: false),
            .init(id: "2", text: NSLocalizedString("우유 사러 가기", comment: ""), importance: 0, done: true),
            .init(id: "3", text: NSLocalizedString("책 한 챕터", comment: ""),  importance: 2, done: false),
        ],
        monthCells: {
            let day = Calendar.current.component(.day, from: Date())
            return [day: WidgetDayCell(todoCount: 3, doneCount: 1, hasMemo: true),
                    max(1, day - 2): WidgetDayCell(todoCount: 2, doneCount: 2, hasMemo: false),
                    min(28, day + 3): WidgetDayCell(todoCount: 5, doneCount: 0, hasMemo: true)]
        }()
    )
}

// MARK: - Memo Widget Data (Large 포스트잇)

struct MemoWidgetData {
    let date: Date
    let memos: [WidgetMemoItem]   // 표시용 (최대 4)
    let totalCount: Int           // 오늘 전체 메모 개수 (+N 계산용)

    static func empty(_ date: Date = Date()) -> MemoWidgetData {
        MemoWidgetData(date: Calendar.current.startOfDay(for: date), memos: [], totalCount: 0)
    }

    static let placeholder = MemoWidgetData(
        date: Calendar.current.startOfDay(for: Date()),
        memos: [
            .init(id: "1", text: NSLocalizedString("운동 30분", comment: ""),   colorName: "yellow"),
            .init(id: "2", text: NSLocalizedString("우유 사러 가기", comment: ""), colorName: "pink"),
            .init(id: "3", text: NSLocalizedString("책 한 챕터", comment: ""),  colorName: "mint"),
            .init(id: "4", text: NSLocalizedString("화분 물주기", comment: ""), colorName: "sky"),
        ],
        totalCount: 4
    )
}

// MARK: - Realm Reader (App Group 공유 Realm, 읽기 전용)

enum WidgetReader {
    /// 위젯은 마이그레이션을 수행하지 않는다(메모리·시간 제한 + 데이터 위험).
    /// 디스크 스키마가 현재 코드와 정확히 일치할 때만 연다. 앱이 아직 새 스키마로
    /// 마이그레이션하기 전이면 nil → 위젯은 빈 상태를 보여주고, 앱 실행 후 reload 로 갱신된다.
    private static func openRealm() -> Realm? {
        guard let url = RealmConfiguration.appGroupURL else { return nil }
        guard let onDisk = try? schemaVersionAtURL(url) else { return nil }
        guard onDisk == RealmConfiguration.schemaVersion else { return nil }
        return try? Realm(configuration: RealmConfiguration.configuration)
    }

    private static func monthBounds(of date: Date) -> (start: Date, end: Date)? {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: date)
        guard let start = cal.date(from: comps),
              let end = cal.date(byAdding: .month, value: 1, to: start) else { return nil }
        return (start, end)
    }

    // MARK: 오늘 위젯 (Small/Medium/Large 공용)
    static func loadToday(date: Date = Date(), todoLimit: Int = 8) -> TodayWidgetData {
        let cal = Calendar.current
        let dayStart = cal.startOfDay(for: date)
        guard let realm = openRealm() else { return .empty(dayStart) }

        let todayTodos = realm.objects(Todo.self)
            .filter("targetDate == %@", dayStart)
            .sorted(byKeyPath: "sortOrder", ascending: true)

        let items: [WidgetTodoItem] = todayTodos.prefix(todoLimit).map {
            WidgetTodoItem(id: $0.objectID.stringValue, text: $0.todo,
                           importance: $0.importance, done: $0.isFinished)
        }

        // 이번 달 일자별 요약 (Large 달력)
        var cells: [Int: WidgetDayCell] = [:]
        if let (mStart, mEnd) = monthBounds(of: date) {
            let monthTodos = realm.objects(Todo.self)
                .filter("targetDate >= %@ AND targetDate < %@", mStart, mEnd)
            for t in monthTodos {
                let d = cal.component(.day, from: t.targetDate)
                cells[d, default: WidgetDayCell()].todoCount += 1
                if t.isFinished { cells[d, default: WidgetDayCell()].doneCount += 1 }
            }
            let monthMemos = realm.objects(QuickNote.self)
                .filter("targetDate >= %@ AND targetDate < %@", mStart, mEnd)
            for m in monthMemos where !m.note.isEmpty {
                let d = cal.component(.day, from: m.targetDate)
                cells[d, default: WidgetDayCell()].hasMemo = true
            }
        }

        return TodayWidgetData(
            date: dayStart,
            todayTodoCount: todayTodos.count,
            todos: Array(items),
            monthCells: cells
        )
    }

    // MARK: 메모 위젯 (Large 포스트잇)
    static func loadMemos(date: Date = Date(), limit: Int = 4) -> MemoWidgetData {
        let cal = Calendar.current
        let dayStart = cal.startOfDay(for: date)
        guard let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart),
              let realm = openRealm() else { return .empty(dayStart) }

        // "오늘 작성된 메모" = regDate 가 오늘인 메모. 앱 MemoRepository 와 동일 기준(regDate 범위).
        // (이전엔 targetDate == startOfDay 로 조회해 표시 안 되는 버그)
        let todayMemos = realm.objects(QuickNote.self)
            .filter("regDate >= %@ AND regDate < %@ AND note != ''", dayStart, dayEnd)
            .sorted(byKeyPath: "regDate", ascending: false)

        let items: [WidgetMemoItem] = todayMemos.prefix(limit).map {
            WidgetMemoItem(id: $0.objectID.stringValue, text: $0.note, colorName: $0.colorName)
        }

        return MemoWidgetData(date: dayStart, memos: Array(items), totalCount: todayMemos.count)
    }
}
