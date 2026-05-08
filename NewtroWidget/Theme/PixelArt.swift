import SwiftUI

// MARK: - Pixel Art Renderer
// 1px-grid 문자열 + 팔레트 → SwiftUI Canvas로 1×1 cell 그리기

struct PixelArt: View {
    let grid: [String]
    let palette: [Character: Color]
    var scale: CGFloat = 2

    private var cols: Int { grid.first?.count ?? 0 }
    private var rows: Int { grid.count }

    var body: some View {
        Canvas { context, size in
            let cell = scale
            for (y, row) in grid.enumerated() {
                for (x, ch) in row.enumerated() {
                    guard let color = palette[ch] else { continue }
                    let rect = CGRect(
                        x: CGFloat(x) * cell,
                        y: CGFloat(y) * cell,
                        width: cell,
                        height: cell
                    )
                    context.fill(Path(rect), with: .color(color))
                }
            }
        }
        .frame(width: CGFloat(cols) * scale, height: CGFloat(rows) * scale)
    }
}

// MARK: - MiniCheck (pixel checkbox)

struct MiniCheck: View {
    var done: Bool
    var size: CGFloat = 14

    var body: some View {
        ZStack {
            Rectangle()
                .fill(done ? Color.done : Color.white)
                .frame(width: size, height: size)
                .pixelBorder(topHighlight: false)

            if done {
                checkmark
            }
        }
        .frame(width: size, height: size)
    }

    private var checkmark: some View {
        // 8x8 checkmark grid
        PixelArt(
            grid: [
                "........",
                "........",
                ".......1",
                "......1.",
                ".1...1..",
                "..1.1...",
                "...1....",
                "........"
            ],
            palette: ["1": .ink],
            scale: max(1, size / 10)
        )
    }
}

// MARK: - MiniIcon (coin / heart / star / flame)

enum MiniIconKind {
    case coin, heart, star, flame
}

struct MiniIcon: View {
    var kind: MiniIconKind
    var scale: CGFloat = 2

    var body: some View {
        switch kind {
        case .coin:
            PixelArt(
                grid: [
                    ".111.",
                    "12221",
                    "12321",
                    "12221",
                    ".111."
                ],
                palette: ["1": .ink, "2": .sun, "3": .peachDk],
                scale: scale
            )
        case .heart:
            PixelArt(
                grid: [
                    ".1.1.",
                    "12121",
                    "12221",
                    ".121.",
                    "..1.."
                ],
                palette: ["1": .ink, "2": .pixelPink],
                scale: scale
            )
        case .star:
            PixelArt(
                grid: [
                    "..1..",
                    ".121.",
                    "12221",
                    ".121.",
                    "..1.."
                ],
                palette: ["1": .ink, "2": .sun],
                scale: scale
            )
        case .flame:
            PixelArt(
                grid: [
                    "..1..",
                    ".121.",
                    "12321",
                    "12321",
                    ".111."
                ],
                palette: ["1": .ink, "2": .peach, "3": .peachDk],
                scale: scale
            )
        }
    }
}

// MARK: - MiniMascot (Pinko)

struct MiniMascot: View {
    var scale: CGFloat = 2
    var color: Color = .pixelPink
    var dark: Color = .pinkDk

    var body: some View {
        PixelArt(
            grid: [
                "..1111..",
                ".122221.",
                "12211221",
                "12222221",
                "12266221",
                "12222221",
                ".111111.",
                "..3..3.."
            ],
            palette: ["1": .ink, "2": color, "6": .white, "3": dark],
            scale: scale
        )
    }
}
