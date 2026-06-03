import SwiftUI

typealias CharacterGridType = PixelArtAssets.CharacterGridType

struct FriendCharInfo: Identifiable {
    let id: String
    let name: String
    let description: String
    let unlockDescription: String
    let gridType: CharacterGridType
    let palette: [Swift.Character: Color]
    // 코인으로 해금되는 마스코트만 값을 가짐. nil = 통계 조건(완료/퍼펙트) 기반 해금.
    let unlockCost: Int?

    init(id: String,
         name: String,
         description: String,
         unlockDescription: String,
         gridType: CharacterGridType,
         palette: [Swift.Character: Color],
         unlockCost: Int? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.unlockDescription = unlockDescription
        self.gridType = gridType
        self.palette = palette
        self.unlockCost = unlockCost
    }
}

enum CharacterData {
    static let all: [FriendCharInfo] = [
        // 1. 핑코 — 기본 캐릭터 (Grid B cat, pink)
        FriendCharInfo(id: "pinko", name: "핑코",
            description: "핑크색 고양이",
            unlockDescription: "기본 캐릭터", gridType: .b, palette: [
            "1": .ink, "2": .pixelPink, "3": .ink, "4": .pinkDk, "5": .cream,
        ]),
        // 2. 삐약 — 5개 완료 (Grid A, yellow chick)
        FriendCharInfo(id: "bbiyak", name: "삐약",
            description: "노란색 병아리",
            unlockDescription: "투두 5개 완료", gridType: .a, palette: [
            "1": .ink, "2": .sun, "3": .ink, "4": .peach, "5": .cream,
        ]),
        // 3. 민티 — 10개 완료 (Grid C bunny, mint)
        FriendCharInfo(id: "minty", name: "민티",
            description: "민트색 토끼",
            unlockDescription: "투두 10개 완료", gridType: .c, palette: [
            "1": .ink, "2": Color(hex: "#AEEBD4"), "3": .ink, "4": .done, "5": .cream,
        ]),
        // 4. 보리 — 25개 완료 (Grid A, brown bear)
        FriendCharInfo(id: "bori", name: "보리",
            description: "갈색 병아리",
            unlockDescription: "투두 25개 완료", gridType: .a, palette: [
            "1": .ink, "2": .dirt, "3": .ink, "4": .dirtDk, "5": .cream,
        ]),
        // 5. 황금이 — 퍼펙트 3회 (Grid B cat, gold)
        FriendCharInfo(id: "hwanggeum", name: "황금이",
            description: "황금색 고양이",
            unlockDescription: "퍼펙트 3회", gridType: .b, palette: [
            "1": .ink, "2": .sun, "3": .ink, "4": Color(hex: "#C8920A"), "5": .cream,
        ]),
        // 6. 블루 — 30개 완료 (Grid C bunny, blue)
        FriendCharInfo(id: "blue", name: "블루",
            description: "파란색 토끼",
            unlockDescription: "투두 30개 완료", gridType: .c, palette: [
            "1": .ink, "2": Color(hex: "#8ECCF5"), "3": .ink, "4": Color(hex: "#3A7FC1"), "5": .white,
        ]),
        // 7. 라일락 — 퍼펙트 7회 (Grid A, lavender)
        FriendCharInfo(id: "lilac", name: "라일락",
            description: "라벤더색 병아리",
            unlockDescription: "퍼펙트 7회", gridType: .a, palette: [
            "1": .ink, "2": Color(hex: "#D4AEFF"), "3": .ink, "4": Color(hex: "#9B6BC8"), "5": .cream,
        ]),
        // 8. 레드 — 75개 완료 (Grid B cat, red)
        FriendCharInfo(id: "red", name: "레드",
            description: "빨간색 고양이",
            unlockDescription: "투두 75개 완료", gridType: .b, palette: [
            "1": .ink, "2": .pixelRed, "3": .cream, "4": .redDk, "5": Color(hex: "#FF9999"),
        ]),
        // 9. 오렌지 — 50개 완료 (Grid A, orange)
        FriendCharInfo(id: "orange", name: "오렌지",
            description: "주황색 병아리",
            unlockDescription: "투두 50개 완료", gridType: .a, palette: [
            "1": .ink, "2": Color(hex: "#FFB347"), "3": .ink, "4": .peachDk, "5": .sun,
        ]),
        // 10. 흑요석 — 150개 완료 (Grid B cat, dark)
        FriendCharInfo(id: "obsidian", name: "흑요석",
            description: "검은색 고양이",
            unlockDescription: "투두 150개 완료", gridType: .b, palette: [
            "1": .ink, "2": Color(hex: "#555566"), "3": .cream, "4": .ink, "5": Color(hex: "#8888AA"),
        ]),
        // 11. 눈꽃 — 퍼펙트 15회 (Grid A, ice white)
        FriendCharInfo(id: "snowflake", name: "눈꽃",
            description: "새하얀 병아리",
            unlockDescription: "퍼펙트 15회", gridType: .a, palette: [
            "1": .ink, "2": Color(hex: "#E8F4FF"), "3": .ink, "4": Color(hex: "#A8D4F0"), "5": .white,
        ]),
        // 12. 별이 — 100개 완료 (Grid C bunny, starlight)
        FriendCharInfo(id: "star", name: "별이",
            description: "별빛색 토끼",
            unlockDescription: "투두 100개 완료", gridType: .c, palette: [
            "1": .ink, "2": .sun, "3": .ink, "4": Color(hex: "#F5D020"), "5": Color(hex: "#FFF5AA"),
        ]),
        // 13. 구름이 — 250개 완료 (Grid A, sky)
        FriendCharInfo(id: "cloud", name: "구름이",
            description: "하늘색 병아리",
            unlockDescription: "투두 250개 완료", gridType: .a, palette: [
            "1": .ink, "2": .white, "3": .ink, "4": .sky, "5": Color(hex: "#E8F4FF"),
        ]),
        // 14. 불꽃 — 퍼펙트 30회 (Grid B cat, fire)
        FriendCharInfo(id: "flame", name: "불꽃",
            description: "불꽃색 고양이",
            unlockDescription: "퍼펙트 30회", gridType: .b, palette: [
            "1": .ink, "2": Color(hex: "#FF6B35"), "3": .ink, "4": Color(hex: "#CC2200"), "5": .sun,
        ]),
        // 15. 물방울 — 200개 완료 (Grid C bunny, aqua)
        FriendCharInfo(id: "water", name: "물방울",
            description: "물빛 토끼",
            unlockDescription: "투두 200개 완료", gridType: .c, palette: [
            "1": .ink, "2": Color(hex: "#80E8FF"), "3": .ink, "4": Color(hex: "#0080CC"), "5": .white,
        ]),
        // 16. 새싹 — 500개 완료 (Grid A, green)
        FriendCharInfo(id: "sprout", name: "새싹",
            description: "초록색 병아리",
            unlockDescription: "투두 500개 완료", gridType: .a, palette: [
            "1": .ink, "2": .grass, "3": .ink, "4": .grassDk, "5": Color(hex: "#CCFF88"),
        ]),
        // 17. 달빛 — 퍼펙트 50회 (Grid C bunny, moonlit)
        FriendCharInfo(id: "moon", name: "달빛",
            description: "달빛색 토끼",
            unlockDescription: "퍼펙트 50회", gridType: .c, palette: [
            "1": .ink, "2": Color(hex: "#D8D0FF"), "3": .ink, "4": Color(hex: "#6050A0"), "5": Color(hex: "#FFFFF0"),
        ]),
        // 18. 태양이 — 365개 완료 (Grid B cat, solar)
        FriendCharInfo(id: "suncat", name: "태양이",
            description: "태양색 고양이",
            unlockDescription: "투두 365개 완료", gridType: .b, palette: [
            "1": .ink, "2": .sun, "3": .ink, "4": Color(hex: "#FF8800"), "5": Color(hex: "#FFFFAA"),
        ]),
        // 19. 무지개 — 1000개 완료 (Grid A, rainbow pastel)
        FriendCharInfo(id: "rainbow", name: "무지개",
            description: "무지개색 병아리",
            unlockDescription: "투두 1000개 완료", gridType: .a, palette: [
            "1": .ink, "2": Color(hex: "#FFB0C8"), "3": .ink, "4": Color(hex: "#FF88AA"), "5": Color(hex: "#FFCCFF"),
        ]),
        // 20. 새벽이 — 퍼펙트 1회 (Grid A, lavender + soft pink)
        FriendCharInfo(id: "dawn", name: "새벽이",
            description: "새벽빛 병아리",
            unlockDescription: "퍼펙트 1회", gridType: .a, palette: [
            "1": .ink, "2": Color(hex: "#E8C8FF"), "3": .ink, "4": Color(hex: "#D898C8"), "5": Color(hex: "#FFF0F8"),
        ]),
        // 21. 풀잎이 — 퍼펙트 100회 (Grid C bunny, grass + earth)
        FriendCharInfo(id: "leaf", name: "풀잎이",
            description: "풀잎색 토끼",
            unlockDescription: "퍼펙트 100회", gridType: .c, palette: [
            "1": .ink, "2": Color(hex: "#A0D870"), "3": .ink, "4": Color(hex: "#5A8B30"), "5": Color(hex: "#E0F0C0"),
        ]),
        // 22. 노을이 — 퍼펙트 200회 (Grid B cat, sunset orange + magenta)
        FriendCharInfo(id: "sunset", name: "노을이",
            description: "노을색 고양이",
            unlockDescription: "퍼펙트 200회", gridType: .b, palette: [
            "1": .ink, "2": Color(hex: "#FF8855"), "3": .ink, "4": Color(hex: "#C84080"), "5": Color(hex: "#FFD8B0"),
        ]),
        // 23. 은하 — 퍼펙트 500회 (Grid A, deep blue + starlight)
        FriendCharInfo(id: "galaxy", name: "은하",
            description: "은하색 병아리",
            unlockDescription: "퍼펙트 500회", gridType: .a, palette: [
            "1": .ink, "2": Color(hex: "#3A4080"), "3": .cream, "4": Color(hex: "#1A1A40"), "5": Color(hex: "#A8B0E0"),
        ]),
        // 24. 시간 — 2000개 완료 (Grid C bunny, royal purple + gold)
        FriendCharInfo(id: "chrono", name: "시간",
            description: "보라색 토끼",
            unlockDescription: "투두 2000개 완료", gridType: .c, palette: [
            "1": .ink, "2": Color(hex: "#9B30FF"), "3": .ink, "4": Color(hex: "#FFD700"), "5": Color(hex: "#E0C0FF"),
        ]),
        // 25. 레전드 — 모든 캐릭터 해금 (Grid D cute, cream face + gold accents + blush)
        FriendCharInfo(id: "legend", name: "레전드",
            description: "끝판왕 고양이",
            unlockDescription: "모든 캐릭터 해금", gridType: .d, palette: [
            "1": .ink,
            "2": .cream,
            "3": .ink,
            "4": .sun,
            "5": .blush,
        ]),
        // ───────────────────────────────────────────────────────────────────
        // 26~31. Grid E 보석 시리즈 — 코인 해금 트랙. 통계 기반 해금(legend 포함)과 완전 분리.
        // 가격은 500 → 4000 의 progression. 1 todo = 1 coin 이므로 흑진주(4000)는 충분히 hard.
        // 코인 마스코트 id 는 StatsRepositoryImpl.coinPurchasedIds 와 동기화 유지.
        // ───────────────────────────────────────────────────────────────────

        // 26. 왕관이 — 500 코인 (Grid E royale, gold face + royal purple + ruby gems)
        FriendCharInfo(id: "royale", name: "왕관이",
            description: "왕관 쓴 황금색 병아리",
            unlockDescription: "보석함에서 데려올 수 있어요", gridType: .e, palette: [
            "1": .ink,
            "2": Color(hex: "#FFD700"),
            "3": .ink,
            "4": Color(hex: "#9B30FF"),
            "5": Color(hex: "#FF3366"),
        ], unlockCost: 500),
        // 27. 루비 — 800 코인 (Grid E, red face + crimson body + bright ruby gems)
        FriendCharInfo(id: "ruby", name: "루비",
            description: "왕관 쓴 루비색 병아리",
            unlockDescription: "보석함에서 데려올 수 있어요", gridType: .e, palette: [
            "1": .ink,
            "2": Color(hex: "#FFCCCC"),
            "3": .ink,
            "4": Color(hex: "#C8102E"),
            "5": Color(hex: "#FF1744"),
        ], unlockCost: 800),
        // 28. 에메랄드 — 1200 코인 (Grid E, mint face + deep green body + emerald gems)
        FriendCharInfo(id: "emerald", name: "에메랄드",
            description: "왕관 쓴 에메랄드색 병아리",
            unlockDescription: "보석함에서 데려올 수 있어요", gridType: .e, palette: [
            "1": .ink,
            "2": Color(hex: "#D4F5E0"),
            "3": .ink,
            "4": Color(hex: "#0E7C3A"),
            "5": Color(hex: "#00C853"),
        ], unlockCost: 1200),
        // 29. 사파이어 — 1800 코인 (Grid E, soft sky face + deep navy body + sapphire gems)
        FriendCharInfo(id: "sapphire", name: "사파이어",
            description: "왕관 쓴 사파이어색 병아리",
            unlockDescription: "보석함에서 데려올 수 있어요", gridType: .e, palette: [
            "1": .ink,
            "2": Color(hex: "#CCE0FF"),
            "3": .ink,
            "4": Color(hex: "#0B3D91"),
            "5": Color(hex: "#1E88E5"),
        ], unlockCost: 1800),
        // 30. 다이아 — 2500 코인 (Grid E, near-white face + silver body + diamond gems)
        FriendCharInfo(id: "diamond", name: "다이아",
            description: "왕관 쓴 다이아색 병아리",
            unlockDescription: "보석함에서 데려올 수 있어요", gridType: .e, palette: [
            "1": .ink,
            "2": Color(hex: "#F0F8FF"),
            "3": .ink,
            "4": Color(hex: "#B0BEC5"),
            "5": Color(hex: "#80DEEA"),
        ], unlockCost: 2500),
        // 31. 흑진주 — 4000 코인 (Grid E, dim face + jet-black body + obsidian gems)
        FriendCharInfo(id: "onyx", name: "흑진주",
            description: "왕관 쓴 흑진주색 병아리",
            unlockDescription: "보석함에서 데려올 수 있어요", gridType: .e, palette: [
            "1": .ink,
            "2": Color(hex: "#888899"),
            "3": .cream,
            "4": Color(hex: "#1A1A22"),
            "5": Color(hex: "#7B61FF"),
        ], unlockCost: 4000),
    ]
}
