import SwiftUI
import WidgetKit

// Large 위젯 ② — 좌상단 "메모" + 우상단 오늘 메모 개수.
// 포스트잇 영역을 항상 2개의 균등 행으로 나눠(각 행 = 영역 높이/2) 포스트잇 높이가 고정된다.
// 텍스트 넘침은 ... / 4개 초과 시 하단 "+N"(전체-4).
struct MemoLargeView: View {
    let data: MemoWidgetData

    private var shown: [WidgetMemoItem] { Array(data.memos.prefix(4)) }
    private var overflow: Int { max(0, data.totalCount - 4) }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("메모")
                    .font(.galBold16())
                    .foregroundColor(.ink)
                Spacer()
                Text("\(data.totalCount)")
                    .font(.galBold14())
                    .foregroundColor(.shade)
            }

            if shown.isEmpty {
                Text("오늘은 메모가 없어요")
                    .font(.galBold14())
                    .foregroundColor(.shade)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                // 2개의 균등 행 — 각 행이 maxHeight 로 동일 분배(영역 높이/2 고정).
                VStack(spacing: 8) {
                    memoRow(0)   // 포스트잇 0, 1
                    memoRow(1)   // 포스트잇 2, 3
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if overflow > 0 {
                    Text("+\(overflow)")
                        .font(.galBold13())
                        .foregroundColor(.shade)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(12)
    }

    @ViewBuilder
    private func memoRow(_ r: Int) -> some View {
        HStack(spacing: 8) {
            cell(r * 2)
            cell(r * 2 + 1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func cell(_ index: Int) -> some View {
        if index < shown.count {
            postIt(shown[index])
        } else {
            Color.clear
        }
    }

    private func postIt(_ memo: WidgetMemoItem) -> some View {
        Text(memo.text)
            .font(.galCondensed16())
            .foregroundColor(.ink)
            .lineLimit(5)
            .truncationMode(.tail)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(8)
            .background(memo.color)
            .pixelBorder(color: .ink, lineWidth: 2)
    }
}
