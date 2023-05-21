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
            switch widgetFamily {
            case .systemMedium:
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
                        }
                    }
                    Image("SettingBackGround")
                        .resizable()
                        .frame(maxWidth: .infinity)
                }
                
            //Large
            case .systemLarge:
                ZStack {
                    if UserDefaults.standard.data(forKey: "KEY") != nil {
                        Image(uiImage: loadImage()!)
                            .resizable()
                            .aspectRatio(1.0, contentMode: .fill)
                        Color.black.opacity(0.2)
                        VStack(alignment: .center, spacing: 0) {
                            HStack(alignment: .center) {
                                VStack {
                                    Text("오늘의 Todo")
                                        .padding(12)
                                        .font(.custom("Galmuri11-Condensed", size: 12))
                                    Text("\(list.count)개")
                                        .font(.custom("Galmuri11-Condensed", size: 12))
                                    Text(String(UserDefaults.standard.data(forKey: "KEY") != nil))
                                        .foregroundColor(.white)
                                }
                                VStack(alignment: .center) {
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
                                }
                            }
                        }
                    } else {
                        Text("이미지 없음")
                    }
                    
                }
                
            @unknown default:
                let count = list.count >= 3 ? 3 : list.count
            }
            
        }
    
    }
    
    func loadImage() -> UIImage? {
         guard let data = UserDefaults.standard.data(forKey: "KEY") else { return UIImage(systemName: "x.square")}
         let decoded = try! PropertyListDecoder().decode(Data.self, from: data)
         let image = UIImage(data: decoded)
        
        return image
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
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct NewtroWidget_Previews: PreviewProvider {
    static var previews: some View {
        NewtroWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
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
