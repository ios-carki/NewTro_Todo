import SwiftUI
import WidgetKit

// Medium 위젯 — 좌상단 "오늘의 할 일" + 오늘 Todo 리스트(완료여부·중요도).
// 공간 초과 시 마지막에 "+N".
struct TodoListMediumView: View {
    let data: TodayWidgetData

    private let maxRows = 4
    private var shown: [WidgetTodoItem] { Array(data.todos.prefix(maxRows)) }
    private var overflow: Int { max(0, data.todayTodoCount - maxRows) }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("오늘의 할 일")
                .font(.galBold16())
                .foregroundColor(.ink)

            if data.todos.isEmpty {
                Spacer(minLength: 0)
                Text("오늘은 할 일이 없어요")
                    .font(.galBold13())
                    .foregroundColor(.shade)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer(minLength: 0)
            } else {
                ForEach(shown) { row($0) }
                if overflow > 0 {
                    Text("+\(overflow)")
                        .font(.galBold11())
                        .foregroundColor(.shade)
                        .padding(.leading, 2)
                }
                Spacer(minLength: 0)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
