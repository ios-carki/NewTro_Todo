//
//  NewtroWidget.swift
//  NewtroWidget
//
//  Created by Carki on 2023/01/12.
//

import WidgetKit
import SwiftUI

import RealmSwift

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        let current = Date()
        
        var entry = SimpleEntry(date: current)
        entries.append(entry)
        
        for i in 0..<1 {
            let todayMonth = Calendar.current.dateComponents([.year, .month, .day, .hour], from: current)
            
            var dateComponents = DateComponents(hour: 0)
            dateComponents.year = todayMonth.year
            dateComponents.month = todayMonth.month
            dateComponents.day = todayMonth.day! + 1
            
            let date = Calendar.current.date(from: dateComponents)
            let secondEntry = SimpleEntry(date: date!)
            entries.append(secondEntry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}


struct NewtroWidgetEntryView : View {
    
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var widgetFamily
    
//    let list = RealmManager.shared.todayTodo(date: Date())
    let list = RealmManager.shared.todayTodo(date: Date())
    
    var body: some View {
        
        ZStack {
            Color(.mainBackGroundColor)
            VStack(alignment: .center, spacing: 0) {
                HStack(alignment: .center) {
                    VStack {
                        Text("오늘의 Todo")
                            .padding(12)
                            .font(.custom("Galmuri11-Condensed", size: 12))
                        Text("\(list.count)개")
                            .font(.custom("Galmuri11-Condensed", size: 12))
                            
                    }
                    VStack(alignment: .center) {
                        switch widgetFamily {
                        case .systemMedium:
                            let count = list.count >= 3 ? 3 : list.count
                            ForEach(0..<count) { i in
                                if count < 3 {
                                    Text(list[i].todo ?? "")
                                        .font(.custom("Galmuri11-Condensed", size: 12))
                                    Divider()
                                } else {
                                    Divider()
                                    Text(list[i].todo ?? "")
                                        .font(.custom("Galmuri11-Condensed", size: 12))
                                }
                            }
                        @unknown default:
                            let count = list.count >= 3 ? 3 : list.count
                        }
//                        Divider()
//                        Text(entry.todo)
//                            .font(.custom("Galmuri11-Condensed", size: 12))
//                        Divider()
//                        Text("테스트")
//                            .font(.custom("Galmuri11-Condensed", size: 12))
//                        Divider()
//                        Text("테스트")
//                            .font(.custom("Galmuri11-Condensed", size: 12))
                    }
                }
                Image("SettingBackGround")
                    .resizable()
                    .frame(maxWidth: .infinity)
            }
        }
    
    }
}

@main
struct NewtroWidget: Widget {
    let kind: String = "NewtroWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            NewtroWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("뉴트로 투두 위젯")
        .description("오늘 작성된 Todo를 확인 해보세요!")
        .supportedFamilies([.systemMedium])
    }
}

struct NewtroWidget_Previews: PreviewProvider {
    static var previews: some View {
        NewtroWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

struct CellView: View {
    let text: String
    
    var body: some View {
        HStack{
            Text(text)
                .font(.system(size: 12))
            Spacer()
        }
    }
}
