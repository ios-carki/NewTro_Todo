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
                Text(String(format: NSLocalizedString("%d개", comment: ""), data.totalCount))
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
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(12)
        .overlay(alignment: .bottomTrailing) {
            if overflow > 0 {
                OverflowChip(count: overflow).padding(8)
            }
        }
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
        // 첫 줄 = 제목(galBold16), 나머지 = 본문(galCondensed16). 앱 메모와 동일.
        let lines = memo.text.components(separatedBy: "\n")
        let title = lines.first ?? ""
        let body = lines.dropFirst().joined(separator: "\n")

        return VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.galBold16())
                .foregroundColor(.ink)
                .lineLimit(1)
                .truncationMode(.tail)

            Text(body)
                .font(.galCondensed16())
                .foregroundColor(.ink.opacity(0.85))
                .lineLimit(4)
                .truncationMode(.tail)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(8)
        .background(memo.color)
        .pixelBorder(color: .ink, lineWidth: 2)
    }
}
