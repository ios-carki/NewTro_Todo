import SwiftUI

// 디자인 시스템의 픽셀 아트 그리드 데이터 (Claude Design 핸드오프 기준)
enum PixelArtAssets {

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

    // MARK: - Trash (10×10) — 편집 화면 하단 삭제 버튼 (빨강 원 안 흰 휴지통)
    //  - row 0: 손잡이 (cols 4-5)
    //  - row 1~2: 뚜껑 (full width → 1칸 살짝 들어옴)
    //  - row 3~7: 통 본체 + 수직 grooves (1px 간격)
    //  - row 8: 통 바닥
    static let dotTrashGrid: [String] = [
        "....11....",
        "1111111111",
        ".11111111.",
        ".1.1.1.1.1",
        ".1.1.1.1.1",
        ".1.1.1.1.1",
        ".1.1.1.1.1",
        ".1.1.1.1.1",
        ".11111111.",
        "..........",
    ]
    static let dotTrashPalette: [Character: Color] = [
        "1": .cream,
    ]

    // MARK: - Bush (22×6) — 잔디 위 우측 가로로 긴 hedge. 3개 bump 패턴.
    static let bushGrid: [String] = [
        "....11....11....11....",
        "...1221221221221221...",
        ".12222222222222222221.",
        "1222222222222222222222",
        "1222222222222222222222",
        "3333333333333333333333",
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

    // MARK: - Mascot Check Dot (10×10) — 저장/확인 도트 버튼 아이콘
    // 마스코트 톤(ink 외곽 + grass 본체 + cream 안쪽 심볼 + grassDk 하단 그림자 띠)
    static let dotCheckGrid: [String] = [
        "1111111111",
        "1222222221",
        "1222222241",
        "1222222421",
        "1222224221",
        "1422242221",
        "1242422221",
        "1224222221",
        "1333333331",
        "1111111111",
    ]
    static let dotCheckPalette: [Character: Color] = [
        "1": .ink, "2": .grass, "3": .grassDk, "4": .cream,
    ]

    // MARK: - Mascot X Dot (10×10) — 취소/닫기 도트 버튼 아이콘
    static let dotXGrid: [String] = [
        "1111111111",
        "1222222221",
        "1244224421",
        "1224444221",
        "1222442221",
        "1222442221",
        "1224444221",
        "1244224421",
        "1333333331",
        "1111111111",
    ]
    static let dotXPalette: [Character: Color] = [
        "1": .ink, "2": .pixelRed, "3": .pinkDk, "4": .cream,
    ]

    // MARK: - Flag (8×8) — 기한 row inline 아이콘. "마감/결승 깃발" 의미.
    // 천: 옆으로 눕힌 M 모양 swallowtail (속이 채워진 형태, 우측 트레일링 엣지에 V-notch).
    //  - row 0/4: 긴 다리 (M 의 외곽 두 변이 가로로 뉘인 형태)
    //  - row 1~3: 우측 V-notch (col 6 → col 5 peak → col 6)
    // 깃대: col 0 전체 height. 천 아래로 4행 더 내려가 "꽂힌" 느낌.
    static let dotFlagGrid: [String] = [
        "11111111",
        "111111..",
        "11111...",
        "111111..",
        "11111111",
        "1.......",
        "1.......",
        "1.......",
    ]
    static let dotFlagPalette: [Character: Color] = [
        "1": .ink,
    ]

    // MARK: - Color Wheel (8×8) — 색상 row inline 아이콘.
    // 원형 ink 외곽 + 3 sectors (좌상=red, 우상=yellow, 하반=green) 으로 분할.
    // 다른 ink 아이콘과 톤이 다르지만 "색상 선택" 메타포를 색 자체로 표현.
    static let dotPaletteGrid: [String] = [
        ".111111.",
        "12223331",
        "12223331",
        "12223331",
        "14444441",
        "14444441",
        "14444441",
        ".111111.",
    ]
    static let dotPalettePalette: [Character: Color] = [
        "1": .ink, "2": .pixelRed, "3": .sun, "4": .grass,
    ]

    // MARK: - Bars (8×8) — 중요도 row inline 아이콘. 막대 3개 상승 (낮음→보통→높음).
    static let dotBarsGrid: [String] = [
        "......11",
        "......11",
        "......11",
        "...11.11",
        "...11.11",
        "11.11.11",
        "11.11.11",
        "11.11.11",
    ]
    static let dotBarsPalette: [Character: Color] = [
        "1": .ink,
    ]

    // MARK: - Bell (8×8) — 알림 row inline 아이콘. 이모지 🔔 대체.
    static let dotBellGrid: [String] = [
        "...11...",
        "..1111..",
        ".111111.",
        ".111111.",
        ".111111.",
        ".111111.",
        "11111111",
        "...11...",
    ]
    static let dotBellPalette: [Character: Color] = [
        "1": .ink,
    ]

    // MARK: - Chevron Right (5×7) — 리스트 push 행의 시각적 affordance 픽셀 아이콘
    // SF Symbol chevron.right 대체. Galmuri 픽셀 톤과 톤매치.
    static let dotChevronRightGrid: [String] = [
        "1....",
        ".1...",
        "..1..",
        "...1.",
        "..1..",
        ".1...",
        "1....",
    ]
    static let dotChevronRightPalette: [Character: Color] = [
        "1": .shade,
    ]

    // MARK: - Home (9×9) — 하위 화면 nav bar trailing 에서 탭 루트로 pop 하는 버튼 아이콘.
    // ink 단색 라인아트 — 지붕 외곽 + 처마(roof base) + 벽 + 문(아치) + 바닥.
    static let dotHomeGrid: [String] = [
        "....1....",
        "...1.1...",
        "..1...1..",
        ".1.....1.",
        "111111111",
        "1.......1",
        "1..111..1",
        "1..1.1..1",
        "1111.1111",
    ]
    static let dotHomePalette: [Character: Color] = [
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

    // Grid D: cute legendary. 둥근 귀 + 큰 눈 + 코 + 볼터치 + 발.
    // Palette keys: 1=outline, 2=face, 3=eye, 4=nose/feet, 5=blush
    static let charGridD: [String] = [
        ".1......1.",
        "121....121",
        "1221111221",
        "1222222221",
        "1235445321",
        "1233223321",
        "1252332521",
        ".12222221.",
        "..144441..",
        "...1..1...",
    ]

    enum CharacterGridType { case a, b, c, d }

    static func characterGrid(type: CharacterGridType) -> [String] {
        switch type {
        case .a: return charGridA
        case .b: return charGridB
        case .c: return charGridC
        case .d: return charGridD
        }
    }
}
