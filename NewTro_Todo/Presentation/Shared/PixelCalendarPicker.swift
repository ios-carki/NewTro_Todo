import SwiftUI

private var pickerWeekdays: [String] {
    var cal = Calendar.current
    cal.locale = Locale.current
    let symbols = cal.veryShortStandaloneWeekdaySymbols
    return symbols.count == 7 ? symbols : ["S", "M", "T", "W", "T", "F", "S"]
}

struct PixelCalendarPicker: View {
    let onDateSelected: (Date) -> Void
    var minimumDate: Date? = nil
    var externalDate: Date? = nil
    var monthOverviewProvider: ((Int, Int) async -> [Int: DayContent])? = nil
    /// (year, month) 가 이미 캐시(루틴 materialize 완료) 됐는지 동기 체크. nil 이면 항상 콜드 미스로 간주.
    /// 콜드 미스일 때만 nav 버튼을 잠그고 cached hit 은 즉시 통과시킨다.
    var cacheCheck: ((Int, Int) -> Bool)? = nil
    var onHeaderTap: (() -> Void)? = nil
    /// isLoading 토글을 외부로 알림 → 시트의 하단 버튼/dismiss 잠금 결정에 사용.
    var onLoadingChange: ((Bool) -> Void)? = nil

    /// year*100 + month. 단일 @State 로 통합해서, 12→1 월처럼 year 와 month 가 동시에 바뀔 때도
    /// 한 프레임에 두 번 onChange 가 발화하지 않도록 한다.
    /// ("onChange(of: Int) action tried to update multiple times per frame" 경고 방지)
    @State private var viewYearMonth: Int
    @State private var dayContent: [Int: DayContent] = [:]
    @State private var reloadTask: Task<Void, Never>? = nil
    @State private var isLoading: Bool = false

    private var viewYear: Int  { viewYearMonth / 100 }
    private var viewMonth: Int { viewYearMonth % 100 }

    init(
        initialDate: Date = Date(),
        minimumDate: Date? = nil,
        externalDate: Date? = nil,
        monthOverviewProvider: ((Int, Int) async -> [Int: DayContent])? = nil,
        cacheCheck: ((Int, Int) -> Bool)? = nil,
        onHeaderTap: (() -> Void)? = nil,
        onLoadingChange: ((Bool) -> Void)? = nil,
        onDateSelected: @escaping (Date) -> Void
    ) {
        let cal = Calendar.current
        let base = externalDate ?? initialDate
        let y = cal.component(.year,  from: base)
        let m = cal.component(.month, from: base)
        _viewYearMonth = State(initialValue: y * 100 + m)
        self.minimumDate   = minimumDate
        self.externalDate  = externalDate
        self.monthOverviewProvider = monthOverviewProvider
        self.cacheCheck = cacheCheck
        self.onHeaderTap = onHeaderTap
        self.onLoadingChange = onLoadingChange
        self.onDateSelected = onDateSelected
    }

    var body: some View {
        VStack(spacing: 0) {
            monthNavPanel
                .padding(.horizontal, 14)

            calendarGrid
                .padding(.horizontal, 14)
                .padding(.top, 10)
        }
        .onAppear { reloadOverview() }
        .onChange(of: viewYearMonth) { _ in reloadOverview() }
        .onChange(of: isLoading) { newValue in onLoadingChange?(newValue) }
        .onChange(of: externalDate) { newDate in
            guard let d = newDate else { return }
            let cal = Calendar.current
            let y = cal.component(.year,  from: d)
            let m = cal.component(.month, from: d)
            viewYearMonth = y * 100 + m
        }
    }

    // MARK: - Month Navigation

    private var monthNavPanel: some View {
        HStack(spacing: 0) {
            Button { prevMonth() } label: {
                Text("◀")
                    .font(.pressStart14())
                    .foregroundColor(.ink)
                    .frame(width: 50, height: 46)
                    .background(Color.cream)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            }
            .disabled(isLoading)
            .opacity(isLoading ? 0.5 : 1)

            HStack(spacing: 6) {
                Text(monthTitle)
                    .font(.pressStart14())
                    .foregroundColor(.ink)
                if onHeaderTap != nil {
                    Text("▼")
                        .font(.pressStart8())
                        .foregroundColor(.ink)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(Color.panel)
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            .opacity(isLoading ? 0.5 : 1)
            .contentShape(Rectangle())
            // isLoading 동안 wheel picker 진입도 막아, 로딩 중 또 다른 점프가 큐잉되는 걸 방지.
            .onTapGesture { if !isLoading { onHeaderTap?() } }

            Button { nextMonth() } label: {
                Text("▶")
                    .font(.pressStart14())
                    .foregroundColor(.ink)
                    .frame(width: 50, height: 46)
                    .background(Color.cream)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            }
            .disabled(isLoading)
            .opacity(isLoading ? 0.5 : 1)
        }
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        PixelPanel(bg: .white, padding: 6) {
            VStack(spacing: 4) {
                weekdayHeader
                dayGrid
            }
        }
        .overlay(loadingOverlay)
    }

    /// 콜드 미스 materialize 중에 캘린더 그리드 위로 떠오르는 픽셀 톤 로딩 카드.
    /// isLoading 이 false 일 땐 EmptyView 라 hit-test/시각 영향 없음.
    @ViewBuilder
    private var loadingOverlay: some View {
        if isLoading {
            ZStack {
                Color.white.opacity(0.7)
                VStack(spacing: 0) {
                    PixelPanel(bg: .cream, padding: 14) {
                        HStack(spacing: 8) {
                            Text("LOADING")
                                .font(.pressStart12())
                                .foregroundColor(.ink)
                            PulsingDots()
                        }
                    }
                    .background(
                        Rectangle()
                            .fill(Color.ink)
                            .offset(x: 3, y: 3)
                    )
                }
            }
            .transition(.opacity)
        }
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { i in
                Text(pickerWeekdays[i])
                    .font(.galBold14())
                    .foregroundColor(i == 0 ? .pixelRed : i == 6 ? .sky : .shade)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
        }
    }

    private var dayGrid: some View {
        let cols = Array(repeating: GridItem(.flexible(), spacing: 3), count: 7)
        return LazyVGrid(columns: cols, spacing: 3) {
            ForEach(Array(cells.enumerated()), id: \.offset) { _, day in
                if let d = day {
                    PickerDayCell(
                        day:         d,
                        isToday:     isToday(day: d),
                        isHighlighted: isHighlighted(day: d),
                        isDisabled:  isDisabled(day: d),
                        weekday:     weekdayOf(day: d),
                        marker:      dayContent[d] ?? DayContent(),
                        onTap:       { selectDay(d) }
                    )
                } else {
                    Color.clear.frame(height: 50)
                }
            }
        }
    }

    // MARK: - Helpers

    private var monthTitle: String { String(format: "%d.%02d", viewYear, viewMonth) }

    private var cells: [Int?] {
        var comps = DateComponents()
        comps.year = viewYear; comps.month = viewMonth; comps.day = 1
        guard let first = Calendar.current.date(from: comps) else { return [] }
        let offset    = Calendar.current.component(.weekday, from: first) - 1
        let daysCount = Calendar.current.range(of: .day, in: .month, for: first)!.count
        return Array(repeating: nil, count: offset) + (1...daysCount).map { Optional($0) }
    }

    private func isToday(day: Int) -> Bool {
        let cal = Calendar.current; let now = Date()
        return cal.component(.year,  from: now) == viewYear &&
               cal.component(.month, from: now) == viewMonth &&
               cal.component(.day,   from: now) == day
    }

    private func isHighlighted(day: Int) -> Bool {
        guard let ext = externalDate else { return false }
        let cal = Calendar.current
        return cal.component(.year,  from: ext) == viewYear &&
               cal.component(.month, from: ext) == viewMonth &&
               cal.component(.day,   from: ext) == day
    }

    private func isDisabled(day: Int) -> Bool {
        guard let min = minimumDate else { return false }
        var comps = DateComponents()
        comps.year = viewYear; comps.month = viewMonth; comps.day = day
        guard let date = Calendar.current.date(from: comps) else { return true }
        return date < Calendar.current.startOfDay(for: min)
    }

    private func weekdayOf(day: Int) -> Int {
        var comps = DateComponents()
        comps.year = viewYear; comps.month = viewMonth; comps.day = day
        guard let date = Calendar.current.date(from: comps) else { return 0 }
        return Calendar.current.component(.weekday, from: date) - 1
    }

    private func selectDay(_ day: Int) {
        guard !isDisabled(day: day) else { return }
        var comps = DateComponents()
        comps.year = viewYear; comps.month = viewMonth; comps.day = day
        guard let date = Calendar.current.date(from: comps) else { return }
        onDateSelected(date)
    }

    private func prevMonth() {
        // year/month 동시 갱신을 한 번의 state 쓰기로 묶어 onChange 가 한 번만 발화하게 한다.
        if viewMonth == 1 {
            viewYearMonth = (viewYear - 1) * 100 + 12
        } else {
            viewYearMonth -= 1
        }
    }

    private func nextMonth() {
        if viewMonth == 12 {
            viewYearMonth = (viewYear + 1) * 100 + 1
        } else {
            viewYearMonth += 1
        }
    }

    private func reloadOverview() {
        // 이전 in-flight 작업은 폐기 (빠른 클릭으로 누적되는 materialize 호출 방지).
        reloadTask?.cancel()
        guard let provider = monthOverviewProvider else { return }
        let y = viewYear, m = viewMonth

        // 캐시 히트면 로딩 상태 없이 즉시 진행 (버튼 비활성화 깜빡임 방지).
        let isColdMiss = (cacheCheck?(y, m) == false)
        if isColdMiss { isLoading = true }

        reloadTask = Task {
            let map = await provider(y, m)
            if Task.isCancelled { return }
            await MainActor.run {
                // race: provider 가 끝나기 전에 사용자가 또 월을 넘긴 경우 결과 폐기.
                guard y == self.viewYear, m == self.viewMonth else {
                    if isColdMiss { self.isLoading = false }
                    return
                }
                self.dayContent = map
                if isColdMiss { self.isLoading = false }
            }
        }
    }
}

// MARK: - Day Cell

private struct PickerDayCell: View {
    let day: Int
    let isToday: Bool
    let isHighlighted: Bool
    let isDisabled: Bool
    let weekday: Int
    let marker: DayContent
    let onTap: () -> Void

    private var bgColor: Color {
        if isHighlighted { return .peach }
        if isToday { return Color(hex: "#FFD6E0").opacity(0.5) }
        return .white
    }

    private var borderColor: Color {
        if isHighlighted { return .peachDk }
        if isToday { return .pixelPink }
        return isDisabled ? .ink.opacity(0.15) : .ink
    }

    private var borderWidth: CGFloat { (isHighlighted || isToday) ? 2.5 : 2 }

    private var dayColor: Color {
        if isDisabled { return .shade.opacity(0.25) }
        if isHighlighted { return .ink }
        switch weekday {
        case 0: return .redDk
        case 6: return Color(hex: "#3A7FC1")
        default: return .ink
        }
    }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // 셀 배경 + 보더
                Rectangle()
                    .fill(isDisabled ? Color.shade.opacity(0.04) : bgColor)
                    .overlay(Rectangle().stroke(borderColor, lineWidth: borderWidth))

                // 날짜 — 셀 정중앙. fold/+N 과 시각적으로 분리되도록 배치.
                Text(String(format: "%02d", day))
                    .font(.pressStart10())
                    .foregroundColor(dayColor)

                // 메모 fold (우상단 코너) — 메모 있을 때만 (개수 표시 없이 플래그만)
                if marker.memoCount > 0 {
                    MemoFoldCorner(isDisabled: isDisabled)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }

                // Todo 사각형 row (하단)
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    todoSquaresRow
                        .padding(.bottom, 5)
                }
            }
            .frame(height: 50)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    // MARK: - Todo 사각형 row
    // 0개: 비움 / 1·2·3개: 그만큼 ▣ / 4개 이상: ▣▣▣ +N (남은 개수)
    //   +N 의 N 은 99 캡 — 99 초과 시 "99+" 한 토큰으로 표시 (셀 폭 오버플로 방지).
    @ViewBuilder
    private var todoSquaresRow: some View {
        if marker.todoCount > 0 {
            HStack(spacing: 2) {
                let shown = min(marker.todoCount, 3)
                ForEach(0..<shown, id: \.self) { _ in todoSquare }
                if marker.todoCount > 3 {
                    let remaining = marker.todoCount - 3
                    Text(remaining > 99 ? "99+" : "+\(remaining)")
                        .font(.pressStart8())
                        .foregroundColor(.ink)
                        .monospacedDigit()
                }
            }
            .opacity(isDisabled ? 0.35 : 1)
            .frame(height: 6)
        } else {
            Color.clear.frame(height: 6)
        }
    }

    private var todoSquare: some View {
        Rectangle()
            .fill(Color.pixelPink)
            .frame(width: 5, height: 5)
            .overlay(Rectangle().stroke(Color.ink.opacity(0.55), lineWidth: 1))
    }
}

// MARK: - Memo Fold Corner
// 우상단 코너가 접힌 종이 모양. "메모 있음" 시각 플래그 전용 (개수 미표시).
private struct MemoFoldCorner: View {
    let isDisabled: Bool

    private let foldSize: CGFloat = 12

    var body: some View {
        ZStack {
            FoldTriangleShape()
                .fill(Color.peachDk)
            FoldEdgeShape()
                .stroke(Color.ink, lineWidth: 1)
        }
        .frame(width: foldSize, height: foldSize)
        .opacity(isDisabled ? 0.35 : 1)
    }
}

// 우상단 → 우하단 → 좌상단을 잇는 직각삼각형 (페이지가 접혀 내려온 면)
private struct FoldTriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        p.closeSubpath()
        return p
    }
}

// 접힘선(좌상단 ↔ 우하단)만 한 줄
private struct FoldEdgeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        return p
    }
}

// MARK: - Loading indicator
// 헤더 옆 작은 점멸 "..." — 콜드 미스 materialize 중에만 등장.
// view 가 사라지면 repeatForever 애니메이션도 자동 정리됨.
private struct PulsingDots: View {
    @State private var pulse = false

    var body: some View {
        Text("...")
            .font(.pressStart10())
            .foregroundColor(.ink)
            .opacity(pulse ? 1 : 0.25)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
    }
}
