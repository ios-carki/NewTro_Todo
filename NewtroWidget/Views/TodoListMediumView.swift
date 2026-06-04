import SwiftUI
import WidgetKit

// Medium 위젯 — 독립 "오늘의 할 일" 레이블(배경 없음) + 투두 리스트 패널.
// 패널 안 행은 "패널 높이 / 4" 로 고정 → 위젯에 최대 4개가 꽉 차게 들어감.
struct TodoListMediumView: View {
    let data: TodayWidgetData

    private let maxRows = 4
    private var hasOverflow: Bool { data.todayTodoCount > maxRows }
    private var visibleTodos: [WidgetTodoItem] {
        Array(data.todos.prefix(hasOverflow ? maxRows - 1 : maxRows))
    }
    private var overflowCount: Int { data.todayTodoCount - visibleTodos.count }

    var body: some View {
        // GeometryReader 를 최상단에 두고 padding 은 바깥 → reader 가 실제 가용 높이를 받음.
        GeometryReader { geo in
            let titleH: CGFloat = 22
            let innerPad: CGFloat = 6
            let panelH = max(0, geo.size.height - titleH - 6)
            let rowH = max(24, (panelH - innerPad * 2) / CGFloat(maxRows))

            VStack(alignment: .leading, spacing: 6) {
                Text("오늘의 할 일")
                    .font(.galBold16())
                    .foregroundColor(.ink)
                    .frame(height: titleH)

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
                .padding(.vertical, innerPad)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Color.cream)
                .pixelBorder(color: .ink, lineWidth: 2)
            }
        }
        .padding(10)
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
