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
}
