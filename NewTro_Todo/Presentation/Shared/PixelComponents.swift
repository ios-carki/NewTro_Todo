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

// MARK: - PxCheckIcon / PxXIcon
// 시트 상단 바의 저장/취소 도트 버튼. 마스코트 톤 픽셀 아이콘 + 충분한 터치 영역.
struct PxCheckIcon: View {
    var scale: CGFloat = 2
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            PixelArtView(
                grid: PixelArtAssets.dotCheckGrid,
                palette: PixelArtAssets.dotCheckPalette,
                scale: scale
            )
            .opacity(disabled ? 0.4 : 1)
            .frame(width: 44, height: 44, alignment: .center)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }
}

struct PxXIcon: View {
    var scale: CGFloat = 2
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            PixelArtView(
                grid: PixelArtAssets.dotXGrid,
                palette: PixelArtAssets.dotXPalette,
                scale: scale
            )
            .frame(width: 44, height: 44, alignment: .center)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
                // 단색 흙 배경
                var x: CGFloat = 0
                ctx.fill(Path(CGRect(x: 0, y: dirtY, width: w, height: size.height - dirtY)), with: .color(.dirt))
                // 중간 수평 음영 선
                ctx.fill(Path(CGRect(x: 0, y: dirtY + (size.height - dirtY) * 0.45, width: w, height: 2)), with: .color(Color.dirtDk.opacity(0.5)))
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
                let pw: CGFloat = 12
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
                let bladeRaise: CGFloat = 6  // 블레이드를 위로 띄우는 오프셋
                x = 0
                while x < w {
                    for (bx, bw, bh, bc) in blades {
                        let fx = x + bx
                        if fx < w {
                            let topY = grassH - bh - bladeRaise
                            let bodyH = bh + bladeRaise  // 아래는 흙에 묻히는 느낌
                            // 블레이드 본체
                            ctx.fill(Path(CGRect(x: fx, y: topY, width: bw, height: bodyH)), with: .color(bc))
                            // 블레이드 상단 하이라이트 (1px 밝게)
                            if bh > 6 {
                                ctx.fill(Path(CGRect(x: fx, y: topY, width: 1, height: 2)), with: .color(Color.grass.opacity(0.7)))
                            }
                        }
                    }
                    x += tileW
                }

                // ─── 상단 ink 경계선 ─────────────────────────────────
                //ctx.fill(Path(CGRect(x: 0, y: 0, width: w, height: 3)), with: .color(.ink))
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
    // 탭 배경 등 정적 사용처에서는 false로 호출 — 드리프트 애니메이션 생략
    var animateClouds: Bool = true

    @State private var cloud1Offset: CGFloat = -80
    @State private var cloud2Offset: CGFloat = 60
    @State private var cloud3Offset: CGFloat = -40
    @State private var cloud4Offset: CGFloat = -100
    @State private var cloud5Offset: CGFloat = 80

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 하늘 그라데이션
                LinearGradient(
                    colors: [.sky, Color(hex: "#A5D8ED")],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                // 구름 4 (상단, 작은)
                PixelArtView(grid: PixelArtAssets.cloudGrid, palette: PixelArtAssets.cloudPalette, scale: 2)
                    .offset(x: cloud4Offset, y: -260)

                // 구름 5 (상단, 큰, 반대 방향)
                PixelArtView(grid: PixelArtAssets.cloudGrid, palette: PixelArtAssets.cloudPalette, scale: 3)
                    .offset(x: geo.size.width - cloud5Offset, y: -180)

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
            guard animateClouds else { return }
            withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) {
                cloud1Offset = 480
            }
            withAnimation(.linear(duration: 55).repeatForever(autoreverses: false)) {
                cloud2Offset = 480
            }
            withAnimation(.linear(duration: 65).repeatForever(autoreverses: false)) {
                cloud3Offset = 480
            }
            withAnimation(.linear(duration: 50).repeatForever(autoreverses: false)) {
                cloud4Offset = 480
            }
            withAnimation(.linear(duration: 70).repeatForever(autoreverses: false)) {
                cloud5Offset = 480
            }
        }
    }
}

// MARK: - BackgroundSceneryView
// Welcome 화면에서 마스코트를 제외한 정적 배경 요소들 (하늘+구름+멀리 언덕+코인+별+부쉬).
// 탭 컨테이너·Settings 등 화면 전체에 깔리는 배경으로 사용. 움직이는 애니메이션은 모두 OFF.
// foreground 슬롯: ground props(부쉬) 보다 아래·코인/별 보다 위에 끼워넣을 뷰.
// WelcomeView 의 걷는 마스코트가 부쉬에 가려야 자연스러우므로 이 슬롯에 마스코트를 넣음.
struct BackgroundSceneryView: View {
    var animateClouds: Bool = false
    var foreground: ((GeometryProxy) -> AnyView)?

    init(animateClouds: Bool = false) {
        self.animateClouds = animateClouds
        self.foreground = nil
    }

    init<V: View>(animateClouds: Bool = false, @ViewBuilder foreground: @escaping (GeometryProxy) -> V) {
        self.animateClouds = animateClouds
        self.foreground = { geo in AnyView(foreground(geo)) }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                SkyBackgroundView(animateClouds: animateClouds)

                // 멀리 산 (좌·우) — ground 보다 z-order 아래라 base 가 흙에 묻혀 자연스럽게 솟아 보임.
                DistantMountain()
                    .fill(Color.grassDk.opacity(0.5))
                    .frame(width: 230, height: 140)
                    .position(x: 80, y: geo.size.height - 95)
                DistantMountain()
                    .fill(Color.grassDk.opacity(0.5))
                    .frame(width: 270, height: 150)
                    .position(x: geo.size.width - 80, y: geo.size.height - 100)

                // 흙+잔디 베이스 — 산보다 위 z-order. 산의 base 가 자연스럽게 흙에 묻힘.
                // height 100 = 잔디 22 + 흙 78. 탭바 top edge(physical bottom + 78pt) 와 흙 top 이 정렬되어
                // 잔디 섹션이 탭바 위로 온전히 노출됨.
                GroundStripView(height: 100)
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)

                // 코인 (우상단)
                PixelArtView(grid: PixelArtAssets.coinGrid, palette: PixelArtAssets.coinPalette, scale: 3)
                    .position(x: geo.size.width - 55, y: geo.size.height - 141)

                // 별 (좌상단)
                PixelArtView(grid: PixelArtAssets.starGrid, palette: PixelArtAssets.starPalette, scale: 2)
                    .position(x: 75, y: geo.size.height - 166)

                // foreground 슬롯 — 부쉬 보다 아래 layer
                if let foreground { foreground(geo) }

                // 부쉬 (잔디 위 우측, 우측 가장자리에 딱 붙음) — 최상단 layer.
                // bushGrid 22×6, scale 3 → 66×18pt. center.x = width - 33 으로 우측 edge 정렬.
                PixelArtView(grid: PixelArtAssets.bushGrid, palette: PixelArtAssets.bushPalette, scale: 3)
                    .position(x: geo.size.width - 33, y: geo.size.height - 89)
            }
        }
    }
}

// 둥글둥글한 산 실루엣. 양쪽 슬로프가 바깥으로 살짝 부풀고 정상은 살짝 라운드 처리.
// 너무 각진 픽셀 산이 아닌, distant background scenery 용 soft hill.
struct DistantMountain: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            let w = rect.width
            let h = rect.height
            p.move(to: CGPoint(x: 0, y: h))
            // 좌측 슬로프 — 바깥으로 살짝 부푸는 곡선
            p.addQuadCurve(
                to: CGPoint(x: w * 0.42, y: h * 0.18),
                control: CGPoint(x: w * 0.16, y: h * 0.62)
            )
            // 둥근 정상 — 살짝 위로 솟음
            p.addQuadCurve(
                to: CGPoint(x: w * 0.58, y: h * 0.18),
                control: CGPoint(x: w * 0.5, y: -h * 0.04)
            )
            // 우측 슬로프 — 좌측과 대칭
            p.addQuadCurve(
                to: CGPoint(x: w, y: h),
                control: CGPoint(x: w * 0.84, y: h * 0.62)
            )
            p.closeSubpath()
        }
    }
}

struct GroundStripView_Preview: PreviewProvider {
    static var previews: some View {
        GroundStripView()
    }
}

