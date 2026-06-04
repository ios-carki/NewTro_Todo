import SwiftUI
import WidgetKit

// Medium 위젯 — 좌상단 "오늘의 할 일" + 우상단 오늘 투두 총 개수("N개").
// 영역을 항상 4개의 균등 슬롯으로 나눠 행 높이 고정(개수 무관). 투두 1개당 개별 카드
// (좌측 중요도 띠 + 선택색 배경). 초과분은 우하단 배경 칩("+N").
struct TodoListMediumView: View {
    let data: TodayWidgetData

    private let maxRows = 4
    private var visibleTodos: [WidgetTodoItem] { Array(data.todos.prefix(maxRows)) }

    private var countText: String {
        String(format: NSLocalizedString("%d개", comment: ""), data.todayTodoCount)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("오늘의 할 일")
                    .font(.galBold16())
                    .foregroundColor(.ink)
                Spacer()
                Text(countText)
                    .font(.galBold13())
                    .foregroundColor(.shade)
            }

            if data.todos.isEmpty {
                Text("오늘은 할 일이 없어요")
                    .font(.galBold13())
                    .foregroundColor(.shade)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
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
        } else {
            Color.clear   // 빈 슬롯 — 배경 노출
        }
    }

    // 투두 1개 = 개별 카드. 좌측에 카드 높이 전체의 중요도 띠, 배경은 Todo 선택색(colorName).
    private func todoCard(_ item: WidgetTodoItem) -> some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(item.priorityColor)
                .frame(width: 6)
                .frame(maxHeight: .infinity)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 1))

            HStack(spacing: 7) {
                Text(item.text)
                    .font(.galCondensed16())
                    .foregroundColor(.ink)
                    .strikethrough(item.done, color: .ink)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(item.bgColor)   // 완료여부와 무관하게 불투명(완료는 취소선으로 구분)
        .pixelBorder(color: .ink, lineWidth: 2)
    }
}
