import SwiftUI

// 디자인 시스템의 픽셀 아트 그리드 데이터 (Claude Design 핸드오프 기준)
enum PixelArtAssets {

    // MARK: - Mascot (16×16)
    static let mascotGrid: [String] = [
        "................",
        ".....111111.....",
        "....12222221....",
        "...1222222221...",
        "...1222222221...",
        "..122222222221..",
        "..133333333331..",
        "..444444444444..",
        ".44455544455544.",
        ".44455544455544.",
        ".44466644466644.",
        ".44444444444444.",
        ".44444555544444.",
        ".44444444444444.",
        "..4444444444....",
        "...44....44.....",
    ]
    static let mascotPalette: [Character: Color] = [
        "1": .ink, "2": .pinkDk, "3": .redDk,
        "4": .pixelPink, "5": .ink, "6": .cream,
    ]

    // MARK: - Cloud (16×7)
    static let cloudGrid: [String] = [
        "....1111........",
        "..11222211......",
        ".1222222211111..",
        "1222222222221..",
        "1222222222222.1",
        ".11222222221111",
        "...1111111111..",
    ]
    static let cloudPalette: [Character: Color] = [
        "1": Color(hex: "#C3E8FA"), "2": .white,
    ]

    // MARK: - Coin (8×8)
    static let coinGrid: [String] = [
        "..1111..",
        ".122221.",
        "12232321",
        "12322231",
        "12322321",
        "12232221",
        ".122221.",
        "..1111..",
    ]
    static let coinPalette: [Character: Color] = [
        "1": .ink, "2": .sun, "3": .cream,
    ]

    // MARK: - Heart (8×7)
    static let heartGrid: [String] = [
        ".11..11.",
        "1221221.",
        "12222221",
        "12222221",
        ".122221.",
        "..1221..",
        "...11...",
    ]
    static let heartPalette: [Character: Color] = [
        "1": .ink, "2": .pixelRed,
    ]

    // MARK: - Star (9×9)
    static let starGrid: [String] = [
        "....1....",
        "....1....",
        "...121...",
        "...121...",
        "111121111",
        ".1222221.",
        "..12221..",
        ".1211121.",
        "11.....11",
    ]
    static let starPalette: [Character: Color] = [
        "1": .ink, "2": .sun,
    ]

    // MARK: - Favorite Star (7×7) — Todo row 즐겨찾기 인디케이터
    static let favoriteStarGrid: [String] = [
        "...1...",
        "...1...",
        ".11211.",
        "1121211",
        ".12221.",
        "..121..",
        ".11.11.",
    ]
    static let favoriteStarPalette: [Character: Color] = [
        "1": .ink, "2": .sun,
    ]

    // MARK: - Bush (12×6)
    static let bushGrid: [String] = [
        "...11..11...",
        "..1221122122",
        ".122222222221",
        "122222222222",
        "122222222222",
        "333333333333",
    ]
    static let bushPalette: [Character: Color] = [
        "1": .ink, "2": .grass, "3": .grassDk,
    ]

    // MARK: - Checkmark (9×7)
    static let checkGrid: [String] = [
        "........1",
        ".......11",
        "......11.",
        "1....11..",
        "11..11...",
        ".1111....",
        "..11.....",
    ]
    static let checkPalette: [Character: Color] = [
        "1": .doneDk,
    ]

    // MARK: - Small Check (5×5) — used for DONE button label
    static let smallCheckGrid: [String] = [
        "....1",
        "...11",
        "1.11.",
        "111..",
        ".1...",
    ]
    static let smallCheckPalette: [Character: Color] = [
        "1": .ink,
    ]

    // MARK: - Arrow Up-Down (5×7) — used for SORT button label
    static let arrowUpDownGrid: [String] = [
        "..1..",
        ".111.",
        "11111",
        ".....",
        "11111",
        ".111.",
        "..1..",
    ]
    static let arrowUpDownPalette: [Character: Color] = [
        "1": .ink,
    ]

    // MARK: - Arrow Down (5×5) — sort: NEW (latest first)
    static let arrowDownGrid: [String] = [
        "..1..",
        "..1..",
        "11111",
        ".111.",
        "..1..",
    ]
    static let arrowDownPalette: [Character: Color] = [
        "1": .ink,
    ]

    // MARK: - Arrow Up (5×5) — sort: OLD (earliest first)
    static let arrowUpGrid: [String] = [
        "..1..",
        ".111.",
        "11111",
        "..1..",
        "..1..",
    ]
    static let arrowUpPalette: [Character: Color] = [
        "1": .ink,
    ]

    // MARK: - Palette (6×5) — sort: HUE (color sort)
    static let palette3Grid: [String] = [
        "112233",
        "112233",
        "112233",
        "112233",
        "112233",
    ]
    static let palette3Palette: [Character: Color] = [
        "1": .pixelRed,
        "2": .sun,
        "3": .grass,
    ]

    // MARK: - Tab Bar Icons (7×7, key "1" = foreground pixel)

    // 할일 — 3 horizontal lines (list)
    static let tabIconTodo: [String] = [
        ".......",
        "1111111",
        ".......",
        "1111111",
        ".......",
        "1111111",
        ".......",
    ]

    // 달력 — calendar with ring binders at top
    static let tabIconCalendar: [String] = [
        "1..1..1",
        "1111111",
        "1.1.1.1",
        "1111111",
        "1.1.1.1",
        "1111111",
        ".......",
    ]

    // 메모 — diagonal pencil (tip bottom-left, eraser top-right)
    static let tabIconMemo: [String] = [
        ".....11",
        "....1.1",
        "...1..1",
        "..1...1",
        ".1....1",
        "1..1111",
        ".11....",
    ]

    // 통계 — ascending bar chart
    static let tabIconStats: [String] = [
        "......1",
        "....1.1",
        "....1.1",
        "..1.1.1",
        "..1.1.1",
        "1111111",
        ".......",
    ]

    // 설정 — gear / cog with 4 teeth
    static let tabIconSettings: [String] = [
        "..1.1..",
        ".11111.",
        "1.1.1.1",
        "1..1..1",
        "1.1.1.1",
        ".11111.",
        "..1.1..",
    ]

    // MARK: - Friend Character Grids (10×10)
    // Palette keys: 1=outline, 2=face, 3=eye, 4=body, 5=blush

    // Grid A: round head
    static let charGridA: [String] = [
        "...1111...",
        "..122221..",
        ".12522521.",
        ".12232321.",
        ".12222221.",
        ".12222221.",
        "..122221..",
        "..144441..",
        ".14444441.",
        "...1..1...",
    ]

    // Grid B: cat ears
    static let charGridB: [String] = [
        ".11...11..",
        "..11111...",
        "..122221..",
        ".12522521.",
        ".12232321.",
        ".12222221.",
        "..122221..",
        "..144441..",
        ".14444441.",
        "...1..1...",
    ]

    // Grid C: bunny ears
    static let charGridC: [String] = [
        "...11.11..",
        "...12.21..",
        "...12.21..",
        "..122221..",
        ".12522521.",
        ".12232321.",
        ".12222221.",
        "..122221..",
        ".14444441.",
        "...1..1...",
    ]

    enum CharacterGridType { case a, b, c }

    static func characterGrid(type: CharacterGridType) -> [String] {
        switch type {
        case .a: return charGridA
        case .b: return charGridB
        case .c: return charGridC
        }
    }
}
