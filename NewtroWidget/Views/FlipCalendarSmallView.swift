import SwiftUI
import WidgetKit

// Small 위젯 — 핑크 그라데이션 위 플립형 달력 카드.
// 상단: 월(로케일별 — 3월/Mar/3月) · 가운데(크게): 오늘 일자 · 하단(크림): 오늘 할 일 N개.
struct FlipCalendarSmallView: View {
    let data: TodayWidgetData

    private var monthText: String {
        let f = DateFormatter()
        f.locale = .current
        f.setLocalizedDateFormatFromTemplate("MMM")   // ko "3월" / en "Mar" / ja·zh "3月"
        return f.string(from: data.date)
    }

    private var countText: String {
        String(format: NSLocalizedString("오늘 할 일 %d개", comment: ""), data.todayTodoCount)
    }

    var body: some View {
        VStack(spacing: 0) {
            // 상단 — 월
            Text(monthText)
                .font(.galBold17())
                .foregroundColor(.cream)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 6)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(Color.pinkDk)

            Rectangle().fill(Color.ink).frame(height: 2)

            // 가운데 — 오늘 일자 (가장 길게)
            Text("\(data.day)")
                .font(.pressStart48())
                .foregroundColor(.ink)
                .minimumScaleFactor(0.6)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.cream)

            Rectangle().fill(Color.ink).frame(height: 2)

            // 하단 — 오늘 할 일 N개 (크림 바탕)
            Text(countText)
                .font(.galBold13())
                .foregroundColor(.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.cream)
        }
        .pixelBorder(color: .ink, lineWidth: 3, topHighlight: false)
        .padding(12)
    }
}
