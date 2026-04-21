import SwiftUI

struct SplashView: View {
    var onTap: (() -> Void)?

    // 깜빡이는 PRESS START
    @State private var blinkVisible = true
    // 걷는 마스코트 X 위치
    @State private var mascotX: CGFloat = -60
    // 마스코트 bob (위아래)
    @State private var mascotBobY: CGFloat = 0
    // 코인 bob
    @State private var coinBobY: CGFloat = 0
    // 별 bob
    @State private var starBobY: CGFloat = 0

    private let blinkTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    private let walkTimer  = Timer.publish(every: 0.06, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // 배경 하늘 + 구름
                SkyBackgroundView()

                // 원거리 언덕 (반투명 잔디색 타원)
                distantHills(geo: geo)

                // 중앙 타이틀 블록
                titleBlock
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.42)

                // 장식 — 코인 (우측 bob)
                PixelArtView(grid: PixelArtAssets.coinGrid, palette: PixelArtAssets.coinPalette, scale: 3)
                    .offset(y: coinBobY)
                    .position(x: geo.size.width - 55, y: geo.size.height - 105)

                // 장식 — 별 (좌측 bob)
                PixelArtView(grid: PixelArtAssets.starGrid, palette: PixelArtAssets.starPalette, scale: 2)
                    .offset(y: starBobY)
                    .position(x: 75, y: geo.size.height - 130)

                // 장식 — 덤불 (우측 바닥)
                PixelArtView(grid: PixelArtAssets.bushGrid, palette: PixelArtAssets.bushPalette, scale: 3)
                    .position(x: geo.size.width - 55, y: geo.size.height - 58)

                // 마스코트 걷기
                PixelArtView(grid: PixelArtAssets.mascotGrid, palette: PixelArtAssets.mascotPalette, scale: 3)
                    .offset(y: mascotBobY)
                    .position(x: mascotX, y: geo.size.height - 65)

                // 바닥 잔디/흙
                GroundStripView()
            }
            .contentShape(Rectangle())
            .onTapGesture { onTap?() }
        }
        .ignoresSafeArea()
        .onReceive(blinkTimer) { _ in
            blinkVisible.toggle()
        }
        .onReceive(walkTimer) { _ in
            mascotX += 2
            // 화면 밖으로 나가면 왼쪽에서 재등장
            if mascotX > UIScreen.main.bounds.width + 60 {
                mascotX = -60
            }
        }
        .onAppear {
            startBobAnimations()
        }
    }

    // MARK: - Title Block
    private var titleBlock: some View {
        VStack(spacing: 16) {
            // 상단 HUD 행
            HStack(spacing: 16) {
                Text("PLAYER ONE")
                    .font(.pressStart9())
                    .foregroundColor(.ink)
                Text("HIGH SCORE")
                    .font(.pressStart9())
                    .foregroundColor(.ink)
                Text("032100")
                    .font(.pressStart9())
                    .foregroundColor(.redDk)
            }

            // 메인 로고
            VStack(spacing: 6) {
                Text("New-Tro")
                    .font(.pressStart34())
                    .foregroundColor(.pinkDk)
                    .rotationEffect(.degrees(-3))
                    .shadow(color: .ink, radius: 0, x: 4, y: 4)
                    .shadow(color: .cream, radius: 0, x: -1, y: -1)

                Text("ToDo!")
                    .font(.pressStart48())
                    .foregroundColor(.sun)
                    .shadow(color: .ink, radius: 0, x: 5, y: 5)
            }

            // 태그라인 패널
            PixelPanel(bg: .cream, padding: 8) {
                Text("레트로 감성 할 일 관리")
                    .font(.galBold16())
                    .foregroundColor(.ink)
            }
            .padding(.top, 8)

            // PRESS START (깜빡임)
            Text("▶  PRESS START")
                .font(.pressStart12())
                .foregroundColor(.ink)
                .opacity(blinkVisible ? 1 : 0)
                .padding(.top, 8)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Distant Hills
    private func distantHills(geo: GeometryProxy) -> some View {
        ZStack {
            Ellipse()
                .fill(Color.grassDk.opacity(0.5))
                .frame(width: 200, height: 90)
                .position(x: 80, y: geo.size.height - 70)
            Ellipse()
                .fill(Color.grassDk.opacity(0.5))
                .frame(width: 230, height: 100)
                .position(x: geo.size.width - 70, y: geo.size.height - 75)
        }
    }

    // MARK: - Bob Animations
    private func startBobAnimations() {
        withAnimation(.easeInOut(duration: 0.45).repeatForever(autoreverses: true)) {
            mascotBobY = -4
        }
        withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
            coinBobY = -5
        }
        withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) {
            starBobY = -4
        }
    }
}
