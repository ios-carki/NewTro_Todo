import SwiftUI

typealias CharacterGridType = PixelArtAssets.CharacterGridType

struct FriendCharInfo: Identifiable {
    let id: String
    let name: String
    let description: String
    let unlockDescription: String
    let gridType: CharacterGridType
    let palette: [Swift.Character: Color]
}

enum CharacterData {
    static let all: [FriendCharInfo] = [
        // 1. 핑코 — 기본 캐릭터 (Grid B cat, pink)
        FriendCharInfo(id: "pinko", name: "핑코",
            description: "분홍빛 고양이. 너의 첫 친구.",
            unlockDescription: "기본 캐릭터", gridType: .b, palette: [
            "1": .ink, "2": .pixelPink, "3": .ink, "4": .pinkDk, "5": .cream,
        ]),
        // 2. 삐약 — 3일 연속 (Grid A, yellow chick)
        FriendCharInfo(id: "bbiyak", name: "삐약",
            description: "노란 병아리. 작은 발걸음, 큰 시작.",
            unlockDescription: "3일 연속", gridType: .a, palette: [
            "1": .ink, "2": .sun, "3": .ink, "4": .peach, "5": .cream,
        ]),
        // 3. 민티 — 10개 완료 (Grid C bunny, mint)
        FriendCharInfo(id: "minty", name: "민티",
            description: "박하향 토끼. 첫 10개의 상쾌함.",
            unlockDescription: "10개 완료", gridType: .c, palette: [
            "1": .ink, "2": Color(hex: "#AEEBD4"), "3": .ink, "4": .done, "5": .cream,
        ]),
        // 4. 보리 — 7일 연속 (Grid A, brown bear)
        FriendCharInfo(id: "bori", name: "보리",
            description: "갈색 곰. 우직함 그 자체.",
            unlockDescription: "7일 연속", gridType: .a, palette: [
            "1": .ink, "2": .dirt, "3": .ink, "4": .dirtDk, "5": .cream,
        ]),
        // 5. 황금이 — 퍼펙트 3회 (Grid B cat, gold)
        FriendCharInfo(id: "hwanggeum", name: "황금이",
            description: "황금빛 고양이. 빛나는 첫 퍼펙트.",
            unlockDescription: "퍼펙트 3회", gridType: .b, palette: [
            "1": .ink, "2": .sun, "3": .ink, "4": Color(hex: "#C8920A"), "5": .cream,
        ]),
        // 6. 블루 — 30개 완료 (Grid C bunny, blue)
        FriendCharInfo(id: "blue", name: "블루",
            description: "푸른 토끼. 단단한 페이스.",
            unlockDescription: "30개 완료", gridType: .c, palette: [
            "1": .ink, "2": Color(hex: "#8ECCF5"), "3": .ink, "4": Color(hex: "#3A7FC1"), "5": .white,
        ]),
        // 7. 라일락 — 퍼펙트 7회 (Grid A, lavender)
        FriendCharInfo(id: "lilac", name: "라일락",
            description: "보랏빛 향기. 우아한 완벽주의자.",
            unlockDescription: "퍼펙트 7회", gridType: .a, palette: [
            "1": .ink, "2": Color(hex: "#D4AEFF"), "3": .ink, "4": Color(hex: "#9B6BC8"), "5": .cream,
        ]),
        // 8. 레드 — 14일 연속 (Grid B cat, red)
        FriendCharInfo(id: "red", name: "레드",
            description: "빨간 고양이. 멈추지 않는 열정.",
            unlockDescription: "14일 연속", gridType: .b, palette: [
            "1": .ink, "2": .pixelRed, "3": .cream, "4": .redDk, "5": Color(hex: "#FF9999"),
        ]),
        // 9. 오렌지 — 50개 완료 (Grid A, orange)
        FriendCharInfo(id: "orange", name: "오렌지",
            description: "주황빛 활기. 50개의 결실.",
            unlockDescription: "50개 완료", gridType: .a, palette: [
            "1": .ink, "2": Color(hex: "#FFB347"), "3": .ink, "4": .peachDk, "5": .sun,
        ]),
        // 10. 흑요석 — 21일 연속 (Grid B cat, dark)
        FriendCharInfo(id: "obsidian", name: "흑요석",
            description: "검은 고양이. 묵묵한 21일의 동반자.",
            unlockDescription: "21일 연속", gridType: .b, palette: [
            "1": .ink, "2": Color(hex: "#555566"), "3": .cream, "4": .ink, "5": Color(hex: "#8888AA"),
        ]),
        // 11. 눈꽃 — 퍼펙트 15회 (Grid A, ice white)
        FriendCharInfo(id: "snowflake", name: "눈꽃",
            description: "차가운 결정. 흔들림 없는 마음.",
            unlockDescription: "퍼펙트 15회", gridType: .a, palette: [
            "1": .ink, "2": Color(hex: "#E8F4FF"), "3": .ink, "4": Color(hex: "#A8D4F0"), "5": .white,
        ]),
        // 12. 별이 — 100개 완료 (Grid C bunny, starlight)
        FriendCharInfo(id: "star", name: "별이",
            description: "별빛 토끼. 반짝이는 100.",
            unlockDescription: "100개 완료", gridType: .c, palette: [
            "1": .ink, "2": .sun, "3": .ink, "4": Color(hex: "#F5D020"), "5": Color(hex: "#FFF5AA"),
        ]),
        // 13. 구름이 — 30일 연속 (Grid A, sky)
        FriendCharInfo(id: "cloud", name: "구름이",
            description: "하늘빛 솜털. 한 달을 함께 떠오른 친구.",
            unlockDescription: "30일 연속", gridType: .a, palette: [
            "1": .ink, "2": .white, "3": .ink, "4": .sky, "5": Color(hex: "#E8F4FF"),
        ]),
        // 14. 불꽃 — 퍼펙트 30회 (Grid B cat, fire)
        FriendCharInfo(id: "flame", name: "불꽃",
            description: "타오르는 고양이. 막을 수 없는 30회.",
            unlockDescription: "퍼펙트 30회", gridType: .b, palette: [
            "1": .ink, "2": Color(hex: "#FF6B35"), "3": .ink, "4": Color(hex: "#CC2200"), "5": .sun,
        ]),
        // 15. 물방울 — 200개 완료 (Grid C bunny, aqua)
        FriendCharInfo(id: "water", name: "물방울",
            description: "청량한 바다빛. 차곡차곡 200.",
            unlockDescription: "200개 완료", gridType: .c, palette: [
            "1": .ink, "2": Color(hex: "#80E8FF"), "3": .ink, "4": Color(hex: "#0080CC"), "5": .white,
        ]),
        // 16. 새싹 — 60일 연속 (Grid A, green)
        FriendCharInfo(id: "sprout", name: "새싹",
            description: "초록빛 새내기. 작아도 멈추지 않아.",
            unlockDescription: "60일 연속", gridType: .a, palette: [
            "1": .ink, "2": .grass, "3": .ink, "4": .grassDk, "5": Color(hex: "#CCFF88"),
        ]),
        // 17. 달빛 — 퍼펙트 50회 (Grid C bunny, moonlit)
        FriendCharInfo(id: "moon", name: "달빛",
            description: "은은한 토끼. 고요한 50회의 헌신.",
            unlockDescription: "퍼펙트 50회", gridType: .c, palette: [
            "1": .ink, "2": Color(hex: "#D8D0FF"), "3": .ink, "4": Color(hex: "#6050A0"), "5": Color(hex: "#FFFFF0"),
        ]),
        // 18. 태양이 — 365개 완료 (Grid B cat, solar)
        FriendCharInfo(id: "suncat", name: "태양이",
            description: "태양의 고양이. 1년의 결실.",
            unlockDescription: "365개 완료", gridType: .b, palette: [
            "1": .ink, "2": .sun, "3": .ink, "4": Color(hex: "#FF8800"), "5": Color(hex: "#FFFFAA"),
        ]),
        // 19. 무지개 — 100일 연속 (Grid A, rainbow pastel)
        FriendCharInfo(id: "rainbow", name: "무지개",
            description: "일곱 빛깔의 전설. 100일의 증거.",
            unlockDescription: "100일 연속", gridType: .a, palette: [
            "1": .ink, "2": Color(hex: "#FFB0C8"), "3": .ink, "4": Color(hex: "#FF88AA"), "5": Color(hex: "#FFCCFF"),
        ]),
        // 20. 새벽이 — 주간 퍼펙트 1회 (Grid A, lavender + soft pink)
        FriendCharInfo(id: "dawn", name: "새벽이",
            description: "첫 일주일의 빛. 어둠 끝의 라벤더.",
            unlockDescription: "주간 퍼펙트 1회", gridType: .a, palette: [
            "1": .ink, "2": Color(hex: "#E8C8FF"), "3": .ink, "4": Color(hex: "#D898C8"), "5": Color(hex: "#FFF0F8"),
        ]),
        // 21. 풀잎이 — 주간 퍼펙트 10회 (Grid C bunny, grass + earth)
        FriendCharInfo(id: "leaf", name: "풀잎이",
            description: "푸른 들의 토끼. 꾸준한 10주의 결실.",
            unlockDescription: "주간 퍼펙트 10회", gridType: .c, palette: [
            "1": .ink, "2": Color(hex: "#A0D870"), "3": .ink, "4": Color(hex: "#5A8B30"), "5": Color(hex: "#E0F0C0"),
        ]),
        // 22. 노을이 — 주간 퍼펙트 30회 (Grid B cat, sunset orange + magenta)
        FriendCharInfo(id: "sunset", name: "노을이",
            description: "노을빛 고양이. 30주의 깊이.",
            unlockDescription: "주간 퍼펙트 30회", gridType: .b, palette: [
            "1": .ink, "2": Color(hex: "#FF8855"), "3": .ink, "4": Color(hex: "#C84080"), "5": Color(hex: "#FFD8B0"),
        ]),
        // 23. 은하 — 주간 퍼펙트 50회 (Grid A, deep blue + starlight)
        FriendCharInfo(id: "galaxy", name: "은하",
            description: "깊은 밤의 별. 50주를 모은 빛.",
            unlockDescription: "주간 퍼펙트 50회", gridType: .a, palette: [
            "1": .ink, "2": Color(hex: "#3A4080"), "3": .cream, "4": Color(hex: "#1A1A40"), "5": Color(hex: "#A8B0E0"),
        ]),
        // 24. 시간 — 주간 퍼펙트 100회 (Grid C bunny, royal purple + gold)
        FriendCharInfo(id: "chrono", name: "시간",
            description: "시간을 모은 자. 100주의 전설.",
            unlockDescription: "주간 퍼펙트 100회", gridType: .c, palette: [
            "1": .ink, "2": Color(hex: "#9B30FF"), "3": .ink, "4": Color(hex: "#FFD700"), "5": Color(hex: "#E0C0FF"),
        ]),
        // 25. 레전드 — 모든 캐릭터 해금 (Grid C, legendary gold/purple)
        FriendCharInfo(id: "legend", name: "레전드",
            description: "빛과 어둠의 전설. 모두를 모은 자.",
            unlockDescription: "모든 캐릭터 해금", gridType: .c, palette: [
            "1": .ink, "2": Color(hex: "#FFD700"), "3": .ink, "4": Color(hex: "#9B30FF"), "5": Color(hex: "#FFE066"),
        ]),
    ]
}
