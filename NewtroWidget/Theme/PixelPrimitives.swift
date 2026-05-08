import SwiftUI

// MARK: - Pixel Border

struct PixelBorder: ViewModifier {
    var color: Color = .ink
    var lineWidth: CGFloat = 2
    var topHighlight: Bool = true

    func body(content: Content) -> some View {
        content
            .overlay(Rectangle().stroke(color, lineWidth: lineWidth))
            .overlay(alignment: .top) {
                if topHighlight {
                    Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .frame(height: lineWidth)
                        .padding(.horizontal, lineWidth)
                }
            }
    }
}

extension View {
    func pixelBorder(color: Color = .ink, lineWidth: CGFloat = 2, topHighlight: Bool = true) -> some View {
        modifier(PixelBorder(color: color, lineWidth: lineWidth, topHighlight: topHighlight))
    }
}

// MARK: - Mini Panel

struct MiniPanel<Content: View>: View {
    var background: Color = .white
    var padding: CGFloat = 6
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(background)
            .pixelBorder()
    }
}

// MARK: - Sky Background

struct SkyBg: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [.sky, .sky, .skyDeep],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // 좌측 위 구름
                CloudShape()
                    .frame(width: 24, height: 6)
                    .position(x: geo.size.width * 0.18, y: geo.size.height * 0.12)

                // 우측 위 구름
                CloudShape()
                    .frame(width: 18, height: 5)
                    .position(x: geo.size.width * 0.78, y: geo.size.height * 0.18)
            }
        }
        .ignoresSafeArea()
    }
}

private struct CloudShape: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle().fill(Color.white)
            Rectangle()
                .fill(Color.white)
                .frame(width: 8, height: 4)
                .offset(x: 8, y: -4)
            Rectangle()
                .fill(Color.white)
                .frame(width: 4, height: 2)
                .offset(x: -4, y: -2)
        }
    }
}

// MARK: - Grass + Dirt Strip (bottom of widget)

struct GrassStrip: View {
    var height: CGFloat = 16

    var body: some View {
        let grassH = max(5, floor(height * 0.4))
        let dirtH = height - grassH

        VStack(spacing: 0) {
            // Top grass blade row (sticking up)
            Rectangle()
                .fill(Color.grass)
                .frame(height: 2)
                .overlay(
                    HStack(spacing: 0) {
                        ForEach(0..<40, id: \.self) { i in
                            Rectangle()
                                .fill(i.isMultiple(of: 2) ? Color.grassDk : Color.clear)
                                .frame(width: 5)
                        }
                    }
                )
            // Grass body
            Rectangle()
                .fill(Color.grass)
                .frame(height: grassH)
                .overlay(
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 2)
                        .frame(maxHeight: .infinity, alignment: .top)
                )
            // Dirt
            Rectangle()
                .fill(Color.dirt)
                .frame(height: dirtH)
                .overlay(
                    HStack(spacing: 0) {
                        ForEach(0..<60, id: \.self) { i in
                            Rectangle()
                                .fill(i.isMultiple(of: 3) ? Color.dirtDk : Color.clear)
                                .frame(width: 4)
                        }
                    }
                )
        }
        .frame(height: height + 2)
    }
}

// MARK: - Pixel Progress Bar

struct PixelProgressBar: View {
    var progress: Double      // 0.0 ... 1.0
    var height: CGFloat = 12

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle().fill(Color.white)
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.grass, .grassDk, .grass, .grassDk],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, geo.size.width * progress))
                    .padding(1)
            }
            .pixelBorder()
        }
        .frame(height: height)
    }
}
