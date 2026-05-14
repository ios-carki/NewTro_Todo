import SwiftUI

// 백업·복구 공용 진행률 모달.
// 진행 중에는 dim 영역 입력 차단, 완료/실패 시에만 확인 버튼 노출.
struct BackupProgressView: View {

    enum Phase: Equatable {
        case running
        case success(String)        // success message (e.g., "백업 완료")
        case failure(String)        // error message

        var isRunning: Bool {
            if case .running = self { return true } else { return false }
        }

        init(_ backupPhase: SettingsViewModel.BackupPhase) {
            switch backupPhase {
            case .idle, .running: self = .running
            case .success:        self = .success("백업 완료".localized())
            case .error(let msg): self = .failure(msg)
            }
        }

        init(_ restorePhase: SettingsViewModel.RestorePhase) {
            switch restorePhase {
            case .idle, .running: self = .running
            case .done:           self = .success("불러오기 완료".localized())
            case .error(let msg): self = .failure(msg)
            }
        }
    }

    let phase: Phase
    let titleKey: LocalizedStringKey   // "데이터 백업" / "데이터 불러오기"
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { /* dim 영역 탭 무반응 */ }

            VStack(spacing: 16) {
                Text(titleKey)
                    .font(.galBold17())
                    .foregroundColor(.ink)

                switch phase {
                case .running:
                    progressBar
                    Text("진행 중")
                        .font(.pressStart9())
                        .foregroundColor(.shade)

                case .success(let msg):
                    pixelCheckMark
                        .frame(width: 60, height: 60)
                    Text(msg)
                        .font(.galBold14())
                        .foregroundColor(.ink)
                        .multilineTextAlignment(.center)
                    confirmButton

                case .failure(let msg):
                    pixelCross
                        .frame(width: 50, height: 50)
                    Text(msg)
                        .font(.galBold14())
                        .foregroundColor(.ink)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    confirmButton
                }
            }
            .padding(20)
            .frame(maxWidth: 300)
            .background(Color.panel)
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 3))
            .background(Rectangle().fill(Color.ink).offset(x: 4, y: 4))
        }
    }

    private var progressBar: some View {
        // indeterminate 게이지 — 좌→우로 흐르는 픽셀 스트라이프
        IndeterminateProgressBar()
            .frame(height: 14)
    }

    private var pixelCheckMark: some View {
        PixelArtView(
            grid: PixelArtAssets.checkGrid,
            palette: PixelArtAssets.checkPalette,
            scale: 6
        )
    }

    private var pixelCross: some View {
        // 9×7 X 모양
        PixelArtView(
            grid: [
                "1.......1",
                "11.....11",
                ".11...11.",
                "..11.11..",
                "...111...",
                "..11.11..",
                ".11...11."
            ],
            palette: ["1": .pixelRed],
            scale: 5
        )
    }

    private var confirmButton: some View {
        Button {
            onConfirm()
        } label: {
            Text("확인")
                .font(.galBold14())
                .foregroundColor(.ink)
                .padding(.horizontal, 20)
                .frame(height: 36)
                .background(Color.peach)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
        }
        .buttonStyle(.plain)
    }
}

// 좌→우 스트라이프 흐름 픽셀 게이지. running 동안 무한 반복.
// repeatForever + offset 애니메이션은 SwiftUI .clipped() 단독으로 안 잘림 → compositingGroup으로
// 한 번 합성 후 mask 적용해야 트랙 밖으로 스트라이프가 새지 않음.
private struct IndeterminateProgressBar: View {
    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack(alignment: .leading) {
                // 트랙 (tile bg + ink stroke)
                Rectangle().fill(Color.tile)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))

                // 스트라이프 패턴 (grass + grassDk 픽셀 점)
                stripes(width: w)
                    .offset(x: offset)
            }
            .frame(width: w, height: h)
            .compositingGroup()
            .mask(Rectangle().frame(width: w, height: h))
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    offset = w
                }
            }
        }
    }

    private func stripes(width: CGFloat) -> some View {
        let step: CGFloat = 8
        let count = Int((width * 2) / step) + 2
        return HStack(spacing: 0) {
            ForEach(0..<count, id: \.self) { i in
                Rectangle()
                    .fill(i % 2 == 0 ? Color.grass : Color.grassDk)
                    .frame(width: step, height: 10)
            }
        }
        .frame(width: width * 2, alignment: .leading)
        .offset(x: -width)
    }
}
