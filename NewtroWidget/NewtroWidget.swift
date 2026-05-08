import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct NewtroEntry: TimelineEntry {
    let date: Date
    let data: WidgetTodayData
}

// MARK: - Provider

struct NewtroProvider: TimelineProvider {
    func placeholder(in context: Context) -> NewtroEntry {
        NewtroEntry(date: Date(), data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (NewtroEntry) -> Void) {
        let data = context.isPreview
            ? WidgetTodayData.placeholder
            : WidgetRealmReader.loadToday()
        completion(NewtroEntry(date: Date(), data: data))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NewtroEntry>) -> Void) {
        let now = Date()
        let data = WidgetRealmReader.loadToday(date: now)
        let entry = NewtroEntry(date: now, data: data)

        // 자정에 다음 날 데이터로 갱신되도록 self-refresh
        let calendar = Calendar.current
        let nextMidnight = calendar.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0),
            matchingPolicy: .nextTime
        ) ?? now.addingTimeInterval(60 * 60)

        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
        completion(timeline)
    }
}

// MARK: - Entry View Router

struct NewtroWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: NewtroEntry

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemSmall:  SmallTodayView(data: entry.data)
        case .systemMedium: MediumListView(data: entry.data)
        case .systemLarge:  LargeTodayView(data: entry.data)
        default:            SmallTodayView(data: entry.data)
        }
    }

    var body: some View {
        if #available(iOS 17.0, *) {
            content.containerBackground(for: .widget) { Color.sky }
        } else {
            ZStack {
                Color.sky
                content
            }
        }
    }
}

// MARK: - Widget Declaration

@main
struct NewtroWidget: Widget {
    let kind: String = "NewtroWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NewtroProvider()) { entry in
            NewtroWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("뉴트로 투두")
        .description("오늘 작성된 Todo를 한 눈에 확인 해보세요!")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Previews (iOS 17+)

@available(iOS 17.0, *)
#Preview("Small", as: .systemSmall) {
    NewtroWidget()
} timeline: {
    NewtroEntry(date: .now, data: .placeholder)
}

@available(iOS 17.0, *)
#Preview("Medium", as: .systemMedium) {
    NewtroWidget()
} timeline: {
    NewtroEntry(date: .now, data: .placeholder)
}

@available(iOS 17.0, *)
#Preview("Large", as: .systemLarge) {
    NewtroWidget()
} timeline: {
    NewtroEntry(date: .now, data: .placeholder)
}
