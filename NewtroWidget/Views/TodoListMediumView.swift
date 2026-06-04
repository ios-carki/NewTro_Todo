import SwiftUI
import WidgetKit

// Medium 위젯 — 독립 "오늘의 할 일" 레이블(배경 없음) + 투두 리스트 패널.
// 패널 안의 행은 위젯에 최대 4개가 들어가도록 고정 높이(패널 높이/4).
struct TodoListMediumView: View {
    let data: TodayWidgetData

    private let maxRows = 4
    private var hasOverflow: Bool { data.todayTodoCount > maxRows }
    private var visibleTodos: [WidgetTodoItem] {
        Array(data.todos.prefix(hasOverflow ? maxRows - 1 : maxRows))
    }
    private var overflowCount: Int { data.todayTodoCount - visibleTodos.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 독립 레이블 — 배경색 없음
            Text("오늘의 할 일")
                .font(.galBold16())
                .foregroundColor(.ink)

            panel
        }
        .padding(10)
    }

    private var panel: some View {
        GeometryReader { geo in
            let rowH = max(22, (geo.size.height - 12) / CGFloat(maxRows))
            VStack(spacing: 0) {
                if data.todos.isEmpty {
                    Spacer(minLength: 0)
                    Text("오늘은 할 일이 없어요")
                        .font(.galBold13())
                        .foregroundColor(.shade)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer(minLength: 0)
                } else {
                    ForEach(visibleTodos) { row($0).frame(height: rowH) }
                    if hasOverflow {
                        Text("+\(overflowCount)")
                            .font(.galBold11())
                            .foregroundColor(.shade)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: rowH)
                    }
                    Spacer(minLength: 0)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .background(Color.cream)
        .pixelBorder(color: .ink, lineWidth: 2)
    }

    private func row(_ item: WidgetTodoItem) -> some View {
        HStack(spacing: 7) {
            MiniCheck(done: item.done, size: 13)

            Rectangle()
                .fill(item.priorityColor)
                .frame(width: 4, height: 14)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 1))

            Text(item.text)
                .font(.galCondensed16())
                .foregroundColor(item.done ? .shade : .ink)
                .strikethrough(item.done, color: .shade)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer(minLength: 0)
        }
    }
}
