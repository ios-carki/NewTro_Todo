import SwiftUI
import WidgetKit

// Medium 위젯 — 독립 "오늘의 할 일" 레이블(배경 없음) + 투두 카드 리스트.
// 영역을 항상 4개의 균등 슬롯으로 나눠(슬롯 = 영역 높이/4) 투두 개수와 무관하게 행 높이 고정.
// 단일 패널이 아니라 투두 1개당 개별 카드(배경+테두리)로 분리해 구분이 명확하다.
// 빈 슬롯은 투명 → 뒤 배경(scenery) 노출.
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

            if data.todos.isEmpty {
                Text("오늘은 할 일이 없어요")
                    .font(.galBold13())
                    .foregroundColor(.shade)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                // 4개 균등 슬롯 — 각 슬롯이 동일 높이로 분배(개수 무관 고정).
                VStack(spacing: 6) {
                    ForEach(0..<maxRows, id: \.self) { i in
                        slot(i)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(10)
    }

    @ViewBuilder
    private func slot(_ index: Int) -> some View {
        if index < visibleTodos.count {
            todoCard(visibleTodos[index])
        } else if hasOverflow && index == visibleTodos.count {
            // 초과 표시 — 카드 없이 텍스트만(투두 카드와 구분)
            Text("+\(overflowCount)")
                .font(.galBold11())
                .foregroundColor(.shade)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 4)
        } else {
            Color.clear   // 빈 슬롯 — 배경 노출
        }
    }

    // 투두 1개 = 개별 카드. 카드 배경색 = 중요도 색(없음=초록/높음=빨강/중간=노랑).
    // 완료는 배경색을 흐리게 + 취소선으로 구분.
    private func todoCard(_ item: WidgetTodoItem) -> some View {
        HStack(spacing: 7) {
            MiniCheck(done: item.done, size: 14)

            Text(item.text)
                .font(.galCondensed16())
                .foregroundColor(.ink)
                .strikethrough(item.done, color: .ink)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(item.priorityColor.opacity(item.done ? 0.45 : 1))
        .pixelBorder(color: .ink, lineWidth: 2)
    }
}
