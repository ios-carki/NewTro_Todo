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
// 고급 픽셀 아트 잔디 + 흙 지면
struct GroundStripView: View {
    var height: CGFloat = 64

    // 잔디 섹션 고정 높이 (나머지는 흙)
    private let grassH: CGFloat = 22

    var body: some View {
        GeometryReader { geo in
            Canvas { ctx, size in
                let w = size.width
                let dirtY = grassH

                // ─── 흙 레이어 ───────────────────────────────────────
                // 베이스 타일 (16pt 격자)
                let tw: CGFloat = 16
                var x: CGFloat = 0
                while x < w {
                    let c: Color = Int(x / tw) % 2 == 0 ? .dirt : .dirtDk
                    ctx.fill(Path(CGRect(x: x, y: dirtY, width: tw, height: size.height - dirtY)), with: .color(c))
                    x += tw
                }
                // 흙 상단 하이라이트 선 (밝은 느낌)
                ctx.fill(Path(CGRect(x: 0, y: dirtY, width: w, height: 2)), with: .color(Color.dirt.opacity(0.85)))
                // 중간 수평 음영 선
                ctx.fill(Path(CGRect(x: 0, y: dirtY + (size.height - dirtY) * 0.45, width: w, height: 2)), with: .color(Color.dirtDk.opacity(0.5)))
                // 하단 어두운 선 (깊이감)
                ctx.fill(Path(CGRect(x: 0, y: size.height - 3, width: w, height: 3)), with: .color(Color.dirtDk))
                // 자갈 (작은 2×2 어두운 사각형)
                let pebbles: [(CGFloat, CGFloat)] = [
                    (18, dirtY+5), (52, dirtY+9), (88, dirtY+4),
                    (130, dirtY+8), (170, dirtY+5), (210, dirtY+10),
                    (248, dirtY+4), (290, dirtY+7), (330, dirtY+9),
                    (36, dirtY+13), (108, dirtY+12), (195, dirtY+13),
                    (270, dirtY+11), (315, dirtY+6),
                ]
                for (px, py) in pebbles {
                    if px < w {
                        ctx.fill(Path(CGRect(x: px, y: py, width: 3, height: 2)), with: .color(.dirtDk))
                        ctx.fill(Path(CGRect(x: px+1, y: py-1, width: 2, height: 1)), with: .color(Color.dirt.opacity(0.4)))
                    }
                }

                // ─── 잔디 레이어 ─────────────────────────────────────
                // 잔디 베이스 (grassDk 바탕)
                ctx.fill(Path(CGRect(x: 0, y: 5, width: w, height: grassH - 5)), with: .color(.grassDk))
                // 밝은 잔디 패치 (격자 8pt)
                let pw: CGFloat = 8
                x = 0
                while x < w {
                    if Int(x / pw) % 3 != 2 {
                        ctx.fill(Path(CGRect(x: x, y: 7, width: pw, height: grassH - 7)), with: .color(.grass))
                    }
                    x += pw
                }

                // 블레이드 패턴 (24pt 반복 타일, 다양한 높이)
                // (xOffset, width, height, color)
                typealias Blade = (CGFloat, CGFloat, CGFloat, Color)
                let blades: [Blade] = [
                    (0,  2, 9,  .grassDk),
                    (3,  1, 6,  .grass),
                    (5,  2, 11, .grass),
                    (8,  1, 7,  .grassDk),
                    (10, 2, 8,  .grass),
                    (13, 1, 5,  .grass),
                    (15, 2, 12, .grassDk),
                    (18, 1, 7,  .grass),
                    (20, 2, 9,  .grass),
                    (23, 1, 6,  .grassDk),
                ]
                let tileW: CGFloat = 26
                x = 0
                while x < w {
                    for (bx, bw, bh, bc) in blades {
                        let fx = x + bx
                        if fx < w {
                            // 블레이드 본체
                            ctx.fill(Path(CGRect(x: fx, y: grassH - bh, width: bw, height: bh)), with: .color(bc))
                            // 블레이드 상단 하이라이트 (1px 밝게)
                            if bh > 6 {
                                ctx.fill(Path(CGRect(x: fx, y: grassH - bh, width: 1, height: 2)), with: .color(Color.grass.opacity(0.7)))
                            }
                        }
                    }
                    x += tileW
                }

                // ─── 상단 ink 경계선 ─────────────────────────────────
                ctx.fill(Path(CGRect(x: 0, y: 0, width: w, height: 3)), with: .color(.ink))
            }
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - BobbingCharView
struct BobbingCharView: View {
    let info: FriendCharInfo
    var scale: CGFloat = 4
    @State private var bobY: CGFloat = 0

    var body: some View {
        PixelArtView(
            grid: PixelArtAssets.characterGrid(type: info.gridType),
            palette: info.palette,
            scale: scale
        )
        .offset(y: bobY)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: bobY)
        .onAppear { bobY = -4 }
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
