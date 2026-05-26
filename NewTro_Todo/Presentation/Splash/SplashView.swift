import SwiftUI

struct SplashView: View {
    var onFinished: (() -> Void)?

    @AppStorage("selectedCharacterId") private var selectedCharacterId: String = "pinko"

    @State private var mascotBobY: CGFloat = 0

    private var selectedCharInfo: FriendCharInfo {
        CharacterData.all.first { $0.id == selectedCharacterId } ?? CharacterData.all[0]
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                BackgroundSceneryView()

                VStack(spacing: 12) {
                    PixelArtView(
                        grid: PixelArtAssets.characterGrid(type: selectedCharInfo.gridType),
                        palette: selectedCharInfo.palette,
                        scale: 4
                    )
                    .offset(y: mascotBobY)

                    VStack(spacing: 4) {
                        Text("New-Tro")
                            .font(.pressStart20())
                            .foregroundColor(.pinkDk)
                            .shadow(color: .ink, radius: 0, x: 3, y: 3)

                        Text("ToDo!")
                            .font(.pressStart34())
                            .foregroundColor(.sun)
                            .shadow(color: .ink, radius: 0, x: 4, y: 4)
                    }
                }
                .position(x: geo.size.width / 2, y: geo.size.height * 0.45)
            }
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                mascotBobY = -6
            }
            // 1.5초 후 자동 전환
            Task {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                await MainActor.run { onFinished?() }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
