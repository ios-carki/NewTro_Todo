import SwiftUI
import WidgetKit

// Large 위젯 ② — 좌상단 "메모" + 우상단 오늘 메모 개수.
// 오늘 작성 메모를 포스트잇 2×2(최대 4)로, 포스트잇 높이는 "가용 높이/2"(2행 고정)로 채움.
// 텍스트 넘침은 ... / 4개 초과 시 하단 "+N"(전체-4).
struct MemoLargeView: View {
    let data: MemoWidgetData

    private var shown: [WidgetMemoItem] { Array(data.memos.prefix(4)) }
    private var overflow: Int { max(0, data.totalCount - 4) }

    var body: some View {
        GeometryReader { geo in
            let headerH: CGFloat = 24
            let rowSpacing: CGFloat = 8
            let overflowH: CGFloat = overflow > 0 ? 22 : 0
            // 헤더·스페이싱·+N 을 뺀 나머지를 2행으로 나눠 포스트잇 높이 결정.
            let gridH = max(0, geo.size.height - headerH - overflowH - 8 - rowSpacing)
            let postItH = max(64, gridH / 2)

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
                .frame(height: headerH)

                if shown.isEmpty {
                    Spacer(minLength: 0)
                    Text("오늘은 메모가 없어요")
                        .font(.galBold14())
                        .foregroundColor(.shade)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer(minLength: 0)
                } else {
                    let cols = [GridItem(.flexible(), spacing: rowSpacing),
                                GridItem(.flexible(), spacing: rowSpacing)]
                    LazyVGrid(columns: cols, spacing: rowSpacing) {
                        ForEach(shown) { postIt($0, height: postItH) }
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
        }
        .padding(12)
    }

    private func postIt(_ memo: WidgetMemoItem, height: CGFloat) -> some View {
        Text(memo.text)
            .font(.galCondensed16())
            .foregroundColor(.ink)
            .lineLimit(5)
            .truncationMode(.tail)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(8)
            .frame(height: height)
            .background(memo.color)
            .pixelBorder(color: .ink, lineWidth: 2)
    }
}
