import SwiftUI

typealias CharacterGridType = PixelArtAssets.CharacterGridType

struct FriendCharInfo: Identifiable {
    let id: String
    let name: String
    let unlockDescription: String
    let gridType: CharacterGridType
    let palette: [Swift.Character: Color]
}

enum CharacterData {
    static let all: [FriendCharInfo] = [
        // 1. 핑코 — 기본 캐릭터 (Grid B cat, pink)
        FriendCharInfo(id: "pinko", name: "핑코", unlockDescription: "기본 캐릭터", gridType: .b, palette: [
            "1": .ink, "2": .pixelPink, "3": .ink, "4": .pinkDk, "5": .cream,
        ]),
        // 2. 삐약 — 3일 연속 (Grid A, yellow chick)
        FriendCharInfo(id: "bbiyak", name: "삐약", unlockDescription: "3일 연속", gridType: .a, palette: [
            "1": .ink, "2": .sun, "3": .ink, "4": .peach, "5": .cream,
        ]),
        // 3. 민티 — 10개 완료 (Grid C bunny, mint)
        FriendCharInfo(id: "minty", name: "민티", unlockDescription: "10개 완료", gridType: .c, palette: [
            "1": .ink, "2": Color(hex: "#AEEBD4"), "3": .ink, "4": .done, "5": .cream,
        ]),
        // 4. 보리 — 7일 연속 (Grid A, brown bear)
        FriendCharInfo(id: "bori", name: "보리", unlockDescription: "7일 연속", gridType: .a, palette: [
            "1": .ink, "2": .dirt, "3": .ink, "4": .dirtDk, "5": .cream,
        ]),
        // 5. 황금이 — 퍼펙트 3회 (Grid B cat, gold)
        FriendCharInfo(id: "hwanggeum", name: "황금이", unlockDescription: "퍼펙트 3회", gridType: .b, palette: [
            "1": .ink, "2": .sun, "3": .ink, "4": Color(hex: "#C8920A"), "5": .cream,
        ]),
        // 6. 블루 — 30개 완료 (Grid C bunny, blue)
        FriendCharInfo(id: "blue", name: "블루", unlockDescription: "30개 완료", gridType: .c, palette: [
            "1": .ink, "2": Color(hex: "#8ECCF5"), "3": .ink, "4": Color(hex: "#3A7FC1"), "5": .white,
        ]),
        // 7. 라일락 — 퍼펙트 7회 (Grid A, lavender)
        FriendCharInfo(id: "lilac", name: "라일락", unlockDescription: "퍼펙트 7회", gridType: .a, palette: [
            "1": .ink, "2": Color(hex: "#D4AEFF"), "3": .ink, "4": Color(hex: "#9B6BC8"), "5": .cream,
        ]),
        // 8. 레드 — 14일 연속 (Grid B cat, red)
        FriendCharInfo(id: "red", name: "레드", unlockDescription: "14일 연속", gridType: .b, palette: [
            "1": .ink, "2": .pixelRed, "3": .cream, "4": .redDk, "5": Color(hex: "#FF9999"),
        ]),
        // 9. 오렌지 — 50개 완료 (Grid A, orange)
        FriendCharInfo(id: "orange", name: "오렌지", unlockDescription: "50개 완료", gridType: .a, palette: [
            "1": .ink, "2": Color(hex: "#FFB347"), "3": .ink, "4": .peachDk, "5": .sun,
        ]),
        // 10. 흑요석 — 21일 연속 (Grid B cat, dark)
        FriendCharInfo(id: "obsidian", name: "흑요석", unlockDescription: "21일 연속", gridType: .b, palette: [
            "1": .ink, "2": Color(hex: "#555566"), "3": .cream, "4": .ink, "5": Color(hex: "#8888AA"),
        ]),
        // 11. 눈꽃 — 퍼펙트 15회 (Grid A, ice white)
        FriendCharInfo(id: "snowflake", name: "눈꽃", unlockDescription: "퍼펙트 15회", gridType: .a, palette: [
            "1": .ink, "2": Color(hex: "#E8F4FF"), "3": .ink, "4": Color(hex: "#A8D4F0"), "5": .white,
        ]),
        // 12. 별이 — 100개 완료 (Grid C bunny, starlight)
        FriendCharInfo(id: "star", name: "별이", unlockDescription: "100개 완료", gridType: .c, palette: [
            "1": .ink, "2": .sun, "3": .ink, "4": Color(hex: "#F5D020"), "5": Color(hex: "#FFF5AA"),
        ]),
        // 13. 구름이 — 30일 연속 (Grid A, sky)
        FriendCharInfo(id: "cloud", name: "구름이", unlockDescription: "30일 연속", gridType: .a, palette: [
            "1": .ink, "2": .white, "3": .ink, "4": .sky, "5": Color(hex: "#E8F4FF"),
        ]),
        // 14. 불꽃 — 퍼펙트 30회 (Grid B cat, fire)
        FriendCharInfo(id: "flame", name: "불꽃", unlockDescription: "퍼펙트 30회", gridType: .b, palette: [
            "1": .ink, "2": Color(hex: "#FF6B35"), "3": .ink, "4": Color(hex: "#CC2200"), "5": .sun,
        ]),
        // 15. 물방울 — 200개 완료 (Grid C bunny, aqua)
        FriendCharInfo(id: "water", name: "물방울", unlockDescription: "200개 완료", gridType: .c, palette: [
            "1": .ink, "2": Color(hex: "#80E8FF"), "3": .ink, "4": Color(hex: "#0080CC"), "5": .white,
        ]),
        // 16. 새싹 — 60일 연속 (Grid A, green)
        FriendCharInfo(id: "sprout", name: "새싹", unlockDescription: "60일 연속", gridType: .a, palette: [
            "1": .ink, "2": .grass, "3": .ink, "4": .grassDk, "5": Color(hex: "#CCFF88"),
        ]),
        // 17. 달빛 — 퍼펙트 50회 (Grid C bunny, moonlit)
        FriendCharInfo(id: "moon", name: "달빛", unlockDescription: "퍼펙트 50회", gridType: .c, palette: [
            "1": .ink, "2": Color(hex: "#D8D0FF"), "3": .ink, "4": Color(hex: "#6050A0"), "5": Color(hex: "#FFFFF0"),
        ]),
        // 18. 태양이 — 365개 완료 (Grid B cat, solar)
        FriendCharInfo(id: "suncat", name: "태양이", unlockDescription: "365개 완료", gridType: .b, palette: [
            "1": .ink, "2": .sun, "3": .ink, "4": Color(hex: "#FF8800"), "5": Color(hex: "#FFFFAA"),
        ]),
        // 19. 무지개 — 100일 연속 (Grid A, rainbow pastel)
        FriendCharInfo(id: "rainbow", name: "무지개", unlockDescription: "100일 연속", gridType: .a, palette: [
            "1": .ink, "2": Color(hex: "#FFB0C8"), "3": .ink, "4": Color(hex: "#FF88AA"), "5": Color(hex: "#FFCCFF"),
        ]),
        // 20. 레전드 — 모든 캐릭터 해금 (Grid C, legendary gold/purple)
        FriendCharInfo(id: "legend", name: "레전드", unlockDescription: "모든 캐릭터 해금", gridType: .c, palette: [
            "1": .ink, "2": Color(hex: "#FFD700"), "3": .ink, "4": Color(hex: "#9B30FF"), "5": Color(hex: "#FFE066"),
        ]),
    ]
}
