import WidgetKit
import SwiftUI

// ════════════════════════════════════════════════════════════════════════
// 위젯 2종으로 구성된 번들.
//  ① "오늘" 위젯 — Small(플립달력) / Medium(투두리스트) / Large(달력)
//  ② "메모" 위젯 — Large(포스트잇)
// 데이터 변경 시 앱이 WidgetCenter.reloadAllTimelines() 로 모든 kind 를 갱신한다.
// ════════════════════════════════════════════════════════════════════════

// MARK: - 공통

private func nextMidnight(after now: Date) -> Date {
    Calendar.current.nextDate(
        after: now,
        matching: DateComponents(hour: 0, minute: 0),
        matchingPolicy: .nextTime
    ) ?? now.addingTimeInterval(60 * 60)
}

// MARK: - ① 오늘 위젯

struct TodayEntry: TimelineEntry {
    let date: Date
    let data: TodayWidgetData
}

struct TodayProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayEntry {
        TodayEntry(date: Date(), data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayEntry) -> Void) {
        let data = context.isPreview ? .placeholder : WidgetReader.loadToday()
        completion(TodayEntry(date: Date(), data: data))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayEntry>) -> Void) {
        let now = Date()
        let entry = TodayEntry(date: now, data: WidgetReader.loadToday(date: now))
        completion(Timeline(entries: [entry], policy: .after(nextMidnight(after: now))))
    }
}

struct TodayEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: TodayEntry

    var body: some View {
        content.widgetBackground(background)
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemSmall:  FlipCalendarSmallView(data: entry.data)
        case .systemMedium: TodoListMediumView(data: entry.data)
        case .systemLarge:  CalendarLargeView(data: entry.data)
        default:            FlipCalendarSmallView(data: entry.data)
        }
    }

    @ViewBuilder
    private var background: some View {
        switch family {
        case .systemSmall:
            LinearGradient(
                colors: [Color(hex: "#FAD4E4"), Color(hex: "#F7A8C8")],
                startPoint: .top, endPoint: .bottom
            )
        default:
            Color.panel
        }
    }
}

struct TodayWidget: Widget {
    let kind = "NewtroTodayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayProvider()) { entry in
            TodayEntryView(entry: entry)
        }
        .configurationDisplayName("오늘")
        .description("오늘의 할 일과 달력을 한눈에")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .disableContentMarginsIfAvailable()
    }
}

// MARK: - ② 메모 위젯

struct MemoEntry: TimelineEntry {
    let date: Date
    let data: MemoWidgetData
}

struct MemoProvider: TimelineProvider {
    func placeholder(in context: Context) -> MemoEntry {
        MemoEntry(date: Date(), data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (MemoEntry) -> Void) {
        let data = context.isPreview ? .placeholder : WidgetReader.loadMemos()
        completion(MemoEntry(date: Date(), data: data))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MemoEntry>) -> Void) {
        let now = Date()
        let entry = MemoEntry(date: now, data: WidgetReader.loadMemos(date: now))
        completion(Timeline(entries: [entry], policy: .after(nextMidnight(after: now))))
    }
}

struct MemoEntryView: View {
    let entry: MemoEntry

    var body: some View {
        MemoLargeView(data: entry.data).widgetBackground(Color.panel)
    }
}

struct MemoWidget: Widget {
    let kind = "NewtroMemoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MemoProvider()) { entry in
            MemoEntryView(entry: entry)
        }
        .configurationDisplayName("메모")
        .description("오늘 작성한 메모를 포스트잇으로")
        .supportedFamilies([.systemLarge])
        .disableContentMarginsIfAvailable()
    }
}

// MARK: - Bundle

@main
struct NewtroWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodayWidget()
        MemoWidget()
    }
}

// MARK: - Helpers

private extension WidgetConfiguration {
    func disableContentMarginsIfAvailable() -> some WidgetConfiguration {
        if #available(iOS 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}

extension View {
    /// iOS 17+ 는 containerBackground, 그 이하는 ZStack 으로 배경을 깐다.
    @ViewBuilder
    func widgetBackground<Background: View>(_ background: Background) -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(for: .widget) { background }
        } else {
            ZStack { background; self }
        }
    }
}

// MARK: - Previews (iOS 17+)

@available(iOS 17.0, *)
#Preview("오늘 Small", as: .systemSmall) { TodayWidget() } timeline: {
    TodayEntry(date: .now, data: .placeholder)
}

@available(iOS 17.0, *)
#Preview("오늘 Medium", as: .systemMedium) { TodayWidget() } timeline: {
    TodayEntry(date: .now, data: .placeholder)
}

@available(iOS 17.0, *)
#Preview("오늘 Large", as: .systemLarge) { TodayWidget() } timeline: {
    TodayEntry(date: .now, data: .placeholder)
}

@available(iOS 17.0, *)
#Preview("메모 Large", as: .systemLarge) { MemoWidget() } timeline: {
    MemoEntry(date: .now, data: .placeholder)
}
