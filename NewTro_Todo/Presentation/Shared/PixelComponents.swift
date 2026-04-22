import SwiftUI

// MARK: - PixelArtView
// 그리드 문자열 + 팔레트로 픽셀 아트를 렌더링하는 범용 뷰
struct PixelArtView: View {
    let grid: [String]
    let palette: [Character: Color]
    let scale: CGFloat

    private var cols: Int { grid.first?.count ?? 0 }
    private var rows: Int { grid.count }

    var body: some View {
        Canvas { ctx, _ in
            for (y, row) in grid.enumerated() {
                for (x, ch) in row.enumerated() {
                    guard let color = palette[ch] else { continue }
                    let rect = CGRect(
                        x: CGFloat(x) * scale, y: CGFloat(y) * scale,
                        width: scale, height: scale
                    )
                    ctx.fill(Path(rect), with: .color(color))
                }
            }
        }
        .frame(width: CGFloat(cols) * scale, height: CGFloat(rows) * scale)
    }
}

// MARK: - PixelPanel
// 4방향 3px ink 테두리 + 크림색 배경 패널
struct PixelPanel<Content: View>: View {
    var bg: Color = .panel
    var padding: CGFloat = 12
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(bg)
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 3))
            .background(Rectangle().fill(Color.ink).offset(x: 4, y: 4))
    }
}

// MARK: - GroundStripView
// 화면 하단 잔디 + 흙 스트립
struct GroundStripView: View {
    var height: CGFloat = 48

    var body: some View {
        VStack(spacing: 0) {
            // 잔디
            grassStrip
            // 흙
            dirtStrip
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .top) {
            Color.ink.frame(height: 3)
        }
    }

    private var grassStrip: some View {
        GeometryReader { geo in
            Canvas { ctx, size in
                let tileW: CGFloat = 10
                var x: CGFloat = 0
                while x < size.width {
                    let color: Color = Int(x / tileW) % 2 == 0 ? .grass : .grassDk
                    ctx.fill(Path(CGRect(x: x, y: 0, width: tileW, height: size.height)), with: .color(color))
                    x += tileW
                }
            }
        }
        .frame(height: 10)
    }

    private var dirtStrip: some View {
        GeometryReader { geo in
            Canvas { ctx, size in
                let tileW: CGFloat = 14
                var x: CGFloat = 0
                while x < size.width {
                    let color: Color = Int(x / tileW) % 2 == 0 ? .dirt : .dirtDk
                    ctx.fill(Path(CGRect(x: x, y: 0, width: tileW, height: size.height)), with: .color(color))
                    x += tileW
                }
                // 수평 흙 라인
                let lineRect = CGRect(x: 0, y: size.height * 0.6, width: size.width, height: 2)
                ctx.fill(Path(lineRect), with: .color(Color.dirtDk.opacity(0.6)))
            }
        }
    }
}

// MARK: - SkyBackgroundView
// 시안 하늘 그라데이션 + 드리프트 구름
struct SkyBackgroundView: View {
    @State private var cloud1Offset: CGFloat = -80
    @State private var cloud2Offset: CGFloat = 60
    @State private var cloud3Offset: CGFloat = -40

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 하늘 그라데이션
                LinearGradient(
                    colors: [.sky, Color(hex: "#A5D8ED")],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                // 구름 1 (큰)
                PixelArtView(grid: PixelArtAssets.cloudGrid, palette: PixelArtAssets.cloudPalette, scale: 3)
                    .offset(x: cloud1Offset, y: 60)

                // 구름 2 (중간, 반대 방향)
                PixelArtView(grid: PixelArtAssets.cloudGrid, palette: PixelArtAssets.cloudPalette, scale: 2)
                    .offset(x: geo.size.width - cloud2Offset, y: 130)

                // 구름 3 (작은)
                PixelArtView(grid: PixelArtAssets.cloudGrid, palette: PixelArtAssets.cloudPalette, scale: 2)
                    .offset(x: cloud3Offset + 40, y: 210)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) {
                cloud1Offset = 480
            }
            withAnimation(.linear(duration: 55).repeatForever(autoreverses: false)) {
                cloud2Offset = 480
            }
            withAnimation(.linear(duration: 65).repeatForever(autoreverses: false)) {
                cloud3Offset = 480
            }
        }
    }
}
