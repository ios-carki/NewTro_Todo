import SwiftUI
import WidgetKit

// Large 위젯 ② — 오늘 작성된 메모를 포스트잇 형태 2×2 그리드(최대 4)로 표시.
// 텍스트 넘침은 ... 로 자름. 4개 초과 시 하단에 "+N"(오늘 전체 메모 - 4).
struct MemoLargeView: View {
    let data: MemoWidgetData

    private var shown: [WidgetMemoItem] { Array(data.memos.prefix(4)) }
    private var overflow: Int { max(0, data.totalCount - 4) }

    var body: some View {
        VStack(spacing: 8) {
            if shown.isEmpty {
                Spacer(minLength: 0)
                Text("오늘은 메모가 없어요")
                    .font(.galBold14())
                    .foregroundColor(.shade)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer(minLength: 0)
            } else {
                let cols = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]
                LazyVGrid(columns: cols, spacing: 8) {
                    ForEach(shown) { postIt($0) }
                }

                if overflow > 0 {
                    Text("+\(overflow)")
                        .font(.galBold13())
                        .foregroundColor(.shade)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }

                Spacer(minLength: 0)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func postIt(_ memo: WidgetMemoItem) -> some View {
        Text(memo.text)
            .font(.galCondensed16())
            .foregroundColor(.ink)
            .lineLimit(4)
            .truncationMode(.tail)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(8)
            .frame(height: 94)
            .background(memo.color)
            .pixelBorder(color: .ink, lineWidth: 2)
    }
}
