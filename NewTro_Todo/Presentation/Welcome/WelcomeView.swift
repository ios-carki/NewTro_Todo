import SwiftUI

struct WelcomeView: View {
    var onTap: (() -> Void)?

    @AppStorage("selectedCharacterId") private var selectedCharacterId: String = "pinko"

    @State private var blinkVisible = true
    @State private var mascotX: CGFloat = -60
    @State private var mascotBobY: CGFloat = 0

    private var selectedCharInfo: FriendCharInfo {
        CharacterData.all.first { $0.id == selectedCharacterId } ?? CharacterData.all[0]
    }

    private let blinkTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    private let walkTimer  = Timer.publish(every: 0.06, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // 걷는 마스코트를 foreground 슬롯에 주입 — 부쉬 layer 보다 아래로 그려져
                // 우측 부쉬를 지날 때 마스코트가 가려진다.
                BackgroundSceneryView { geo in
                    PixelArtView(
                        grid: PixelArtAssets.characterGrid(type: selectedCharInfo.gridType),
                        palette: selectedCharInfo.palette,
                        scale: 3
                    )
                    .offset(y: mascotBobY)
                    .position(x: mascotX, y: geo.size.height - 100)
                }

                titleBlock
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.42)
            }
            .contentShape(Rectangle())
            .onTapGesture { onTap?() }
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .onReceive(blinkTimer) { _ in blinkVisible.toggle() }
        .onReceive(walkTimer) { _ in
            mascotX += 2
            if mascotX > UIScreen.main.bounds.width + 60 { mascotX = -60 }
        }
        .onAppear { startBobAnimations() }
    }

    // MARK: - Title Block
    private var titleBlock: some View {
        VStack(spacing: 16) {
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

            PixelPanel(bg: .cream, padding: 8) {
                Text("레트로 감성 할 일 관리")
                    .font(.galBold16())
                    .foregroundColor(.ink)
            }
            .padding(.top, 8)

            Text("▶  PRESS START")
                .font(.pressStart12())
                .foregroundColor(.ink)
                .opacity(blinkVisible ? 1 : 0)
                .padding(.top, 8)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Bob Animations
    private func startBobAnimations() {
        withAnimation(.easeInOut(duration: 0.45).repeatForever(autoreverses: true)) { mascotBobY = -4 }
    }
}
