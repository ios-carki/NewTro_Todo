import SwiftUI
import WidgetKit

// Medium 위젯 — 독립 "오늘의 할 일" 레이블(배경 없음) + 투두 리스트 패널.
// 패널을 항상 4개의 균등 슬롯으로 나눠(각 슬롯 = 패널 높이/4) 투두 개수와 무관하게
// 행 높이가 고정된다. 즉 1·2·4개 어느 경우든 한 행 높이는 동일하고, 최대 4개가 보인다.
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
            Text("오늘의 할 일")
                .font(.galBold16())
                .foregroundColor(.ink)

            panel
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(10)
    }

    private var panel: some View {
        Group {
            if data.todos.isEmpty {
                Text("오늘은 할 일이 없어요")
                    .font(.galBold13())
                    .foregroundColor(.shade)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                // 4개의 균등 슬롯 — 각 슬롯이 maxHeight 로 동일 분배됨(패널 높이/4 고정).
                VStack(spacing: 0) {
                    ForEach(0..<maxRows, id: \.self) { i in
                        slot(i)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.cream)
        .pixelBorder(color: .ink, lineWidth: 2)
    }

    @ViewBuilder
    private func slot(_ index: Int) -> some View {
        if index < visibleTodos.count {
            row(visibleTodos[index])
        } else if hasOverflow && index == visibleTodos.count {
            Text("+\(overflowCount)")
                .font(.galBold11())
                .foregroundColor(.shade)
        } else {
            Color.clear
        }
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
