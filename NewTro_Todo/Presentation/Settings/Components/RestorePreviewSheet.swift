import SwiftUI

// 데이터 불러오기 — 파일 선택 후 메타데이터 미리보기 + 모드 선택 모달.
// 디자인 시스템: panel bg + ink 3px stroke + 4pt offset shadow, 위험 동작은 pixelRed.
struct RestorePreviewSheet: View {

    let header: BackupHeader
    let onMerge: () -> Void
    let onOverwrite: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { /* dim 영역 탭 무반응 */ }

            VStack(alignment: .leading, spacing: 14) {

                Text("⚠ 복구 확인")
                    .font(.galBold17())
                    .foregroundColor(.ink)
                    .frame(maxWidth: .infinity)

                Divider().background(Color.ink.opacity(0.3))

                VStack(alignment: .leading, spacing: 6) {
                    Text("백업 파일")
                        .font(.pressStart8())
                        .foregroundColor(.shade)
                    Text("생성일: \(formatDate(header.createdAt))")
                        .font(.galBold13())
                        .foregroundColor(.ink)
                    Text(countsLine())
                        .font(.galBold13())
                        .foregroundColor(.ink)
                }

                Divider().background(Color.ink.opacity(0.3))

                Text("불러올 방식을 선택하세요.")
                    .font(.galBold13())
                    .foregroundColor(.ink)

                modeButton(
                    titleKey: "합치기 (추천)",
                    descKey: "현재 데이터는 그대로 두고 백업의 항목을 추가합니다.",
                    bg: .sun,
                    action: onMerge
                )
                modeButton(
                    titleKey: "새로 덮어쓰기",
                    descKey: "현재 데이터를 모두 지우고 백업으로 교체합니다.\n이 작업은 되돌릴 수 없습니다.",
                    bg: .pixelRed,
                    fg: .white,
                    action: onOverwrite
                )

                Button { onCancel() } label: {
                    Text("취소")
                        .font(.galBold14())
                        .foregroundColor(.ink)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Color.tile)
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                        .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .padding(18)
            .frame(maxWidth: 320)
            .background(Color.panel)
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 3))
            .background(Rectangle().fill(Color.ink).offset(x: 4, y: 4))
            .padding(.horizontal, 20)
        }
    }

    @ViewBuilder
    private func modeButton(
        titleKey: LocalizedStringKey,
        descKey: LocalizedStringKey,
        bg: Color,
        fg: Color = .ink,
        action: @escaping () -> Void
    ) -> some View {
        Button { action() } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(titleKey)
                    .font(.galBold14())
                    .foregroundColor(fg)
                Text(descKey)
                    .font(.galBold11())
                    .foregroundColor(fg.opacity(0.85))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(bg)
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
        }
        .buttonStyle(.plain)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }

    private func countsLine() -> String {
        let c = header.counts
        let template = "할일 %d · 메모 %d · 템플릿 %d · 미루기 %d".localized()
        return String(format: template, c.todo, c.quickNote, c.template, c.postpone)
    }
}
