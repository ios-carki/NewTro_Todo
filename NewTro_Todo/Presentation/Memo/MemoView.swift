import SwiftUI

struct MemoView: View {
    @ObservedObject var viewModel: MemoViewModel
    @State private var isRangePickerPresented: Bool = false
    @AppStorage("selectedCharacterId") private var selectedCharacterId: String = "pinko"
    // 뷰 모드 — 앱 재실행 후에도 유지되도록 AppStorage 사용. "postIt" | "list"
    @AppStorage("memoViewMode") private var viewModeRaw: String = MemoViewMode.postIt.rawValue
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private let tabBarHeight: CGFloat = 113

    // 컴팩트 폭(iPhone 전체, iPad 1/2 split 등)은 2열, 레귤러 폭(iPad 풀스크린/2-3 split)은 3열.
    private var columnCount: Int {
        horizontalSizeClass == .regular ? 3 : 2
    }

    private var viewMode: MemoViewMode {
        MemoViewMode(rawValue: viewModeRaw) ?? .postIt
    }

    private var selectedCharInfo: FriendCharInfo {
        CharacterData.all.first { $0.id == selectedCharacterId } ?? CharacterData.all[0]
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.top, 8)

            controlPanel
                .padding(.horizontal, 16)
                .padding(.top, 8)

            memoGrid
                .padding(.top, 8)
        }
        .overlay {
            if isRangePickerPresented {
                MemoRangePicker(
                    initialFrom: viewModel.rangeFrom,
                    initialTo: viewModel.rangeTo,
                    onApply: { from, to in
                        viewModel.rangeFrom = from
                        viewModel.rangeTo = to
                        viewModel.applyRangeFilter()
                        isRangePickerPresented = false
                    },
                    onClose: { isRangePickerPresented = false }
                )
            } else if viewModel.isCreatePresented {
                MemoCreateView(viewModel: viewModel)
            } else if viewModel.isFormPresented, let memo = viewModel.editingMemo {
                MemoFormView(memo: memo, viewModel: viewModel)
            }
        }
        .alert("오류", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("확인") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear { viewModel.loadMemos() }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Text("메모장")
                .font(.galBold22())
                .foregroundColor(.ink)
            Spacer()
            Button {
                viewModel.presentCreate()
            } label: {
                Text("+ 작성")
                    .font(.galBold11())
                    .foregroundColor(.cream)
                    .padding(.horizontal, 12)
                    .frame(height: 34)
                    .background(Color.peachDk)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                    .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: - Control Panel (filter + sort + view mode)
    private var controlPanel: some View {
        VStack(spacing: 8) {
            filterRow
            sortRow
            viewModeRow
        }
        .padding(10)
        .background(Color.cream)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
    }

    // MARK: - Filter Row
    private var filterRow: some View {
        HStack(spacing: 6) {
            filterChip(.all)
            filterChip(.today)
            filterChip(.days(7))
            filterChip(.days(30))
            rangeChip
            Spacer()
        }
    }

    private func filterChip(_ filter: MemoFilter) -> some View {
        let isActive = viewModel.filterType == filter
        return Button {
            viewModel.selectFilter(filter)
        } label: {
            Text(filter.label)
                .font(.galBold10())
                .foregroundColor(isActive ? .cream : .ink)
                .padding(.horizontal, 8)
                .frame(height: 26)
                .background(isActive ? Color.ink : Color.panel)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
        }
    }

    private var rangeChip: some View {
        let isActive = viewModel.isRangeFilterActive
        return Button {
            isRangePickerPresented = true
        } label: {
            Text("기간")
                .font(.galBold10())
                .foregroundColor(isActive ? .cream : .ink)
                .padding(.horizontal, 8)
                .frame(height: 26)
                .background(isActive ? Color.ink : Color.panel)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
        }
    }

    // MARK: - Sort Row
    private var sortRow: some View {
        HStack(spacing: 6) {
            Text("정렬")
                .font(.galBold9())
                .foregroundColor(.shade)

            ForEach(MemoSortType.allCases, id: \.self) { type in
                sortButton(type)
            }

            Spacer()

            Text("\(viewModel.memos.count)")
                .font(.pressStart9())
                .foregroundColor(.ink)
        }
    }

    private func sortButton(_ type: MemoSortType) -> some View {
        let isActive = viewModel.sortType == type
        return Button {
            viewModel.sortType = type
        } label: {
            Text(type.displayName)
                .font(.galBold9())
                .foregroundColor(.ink)
                .padding(.horizontal, 6)
                .frame(height: 22)
                .background(isActive ? Color.sun : Color.panel)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
        }
    }

    // MARK: - View Mode Row
    private var viewModeRow: some View {
        HStack(spacing: 6) {
            Text("보기")
                .font(.galBold9())
                .foregroundColor(.shade)

            viewModeButton(.postIt)
            viewModeButton(.list)

            Spacer()
        }
    }

    private func viewModeButton(_ mode: MemoViewMode) -> some View {
        let isActive = viewMode == mode
        return Button {
            viewModeRaw = mode.rawValue
        } label: {
            Text(mode.displayName)
                .font(.galBold9())
                .foregroundColor(.ink)
                .padding(.horizontal, 6)
                .frame(height: 22)
                .background(isActive ? Color.sun : Color.panel)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
        }
    }

    // MARK: - Memo Grid (mode-aware)
    private var memoGrid: some View {
        ScrollView {
            if viewModel.displayedMemos.isEmpty {
                emptyState.padding(.top, 60)
            } else {
                Group {
                    switch viewMode {
                    case .postIt: postItGrid
                    case .list:   listColumn
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, tabBarHeight + 16)
            }
        }
    }

    private var postItGrid: some View {
        let memos = viewModel.displayedMemos
        let count = columnCount
        let columns: [[MemoEntity]] = (0..<count).map { col in
            memos.enumerated().filter { $0.offset % count == col }.map(\.element)
        }

        // 각 컬럼에 maxWidth: .infinity를 강제해 메모 개수가 1개여도
        // 카드 너비가 N개 일때와 동일하게 유지되도록 함.
        return HStack(alignment: .top, spacing: 12) {
            ForEach(0..<count, id: \.self) { col in
                VStack(spacing: 12) {
                    ForEach(columns[col]) { memo in
                        MemoCardView(memo: memo)
                            .onTapGesture { viewModel.openMemo(memo) }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .top)
            }
        }
    }

    private var listColumn: some View {
        VStack(spacing: 10) {
            ForEach(viewModel.displayedMemos) { memo in
                MemoListCellView(memo: memo)
                    .onTapGesture { viewModel.openMemo(memo) }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            PixelPanel(bg: .cream, padding: 16) {
                VStack(spacing: 10) {
                    BobbingCharView(info: selectedCharInfo)
                    Text("오늘은 메모가 없어요")
                        .font(.galBold14())
                        .foregroundColor(.ink)
                    Text("+ 작성 버튼으로 추가해보세요!")
                        .font(.galBold11())
                        .foregroundColor(.shade.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Memo Card (dog-ear style, fixed height)
private struct MemoCardView: View {
    let memo: MemoEntity
    private let cornerSize: CGFloat = 18
    // 카드 자체를 고정 높이로 — 본문 분량과 무관하게 동일 타일 크기.
    // 짧은 메모는 위쪽 정렬 + 하단 여백, 긴 메모는 영역 내에서 자연 truncation(…).
    private let cardHeight: CGFloat = 180
    // 본문 영역 = cardHeight - 상하 padding(20) - timestamp 영역(~30) - 간격(8) ≈ 122pt
    // galCondensed13 lineHeight ≈ 16pt → 7줄 안전 상한.
    private let bodyLineLimit: Int = 7

    private var bodyText: String { memo.isWritten ? memo.note : "..." }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                Text(bodyText)
                    .font(.galCondensed13())
                    .foregroundColor(.ink)
                    .lineLimit(bodyLineLimit)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                MemoTimestampStamp(date: memo.createdAt)
                    .padding(.top, 8)
            }
            .padding(10)
            .padding(.trailing, cornerSize - 4)
            .frame(height: cardHeight, alignment: .top)
            .background(MemoColorPalette.color(for: memo.colorName))
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))

            DogEarShape(size: cornerSize)
                .fill(Color.ink.opacity(0.25))
                .frame(width: cornerSize, height: cornerSize)
        }
    }
}

// MARK: - Memo List Cell (left color strip + title/body/+N줄 + date stamp)
// 셀 배경 = cream, 좌측 띠 = 메모 색상.
// 첫 줄 = title (galBold14), 나머지 = body (galCondensed13).
// 본문은 최대 2줄(전체 3줄)까지 노출, 초과 시 "+N줄" 레이블 노출.
private struct MemoListCellView: View {
    let memo: MemoEntity
    private let stripWidth: CGFloat = 8
    private let bodyMaxLines: Int = 2

    private var noteText: String { memo.isWritten ? memo.note : "..." }
    private var lines: [String] { noteText.components(separatedBy: "\n") }
    private var title: String { lines.first ?? "" }
    private var bodyLines: [String] { Array(lines.dropFirst()) }
    private var visibleBody: String {
        bodyLines.prefix(bodyMaxLines).joined(separator: "\n")
    }
    private var hiddenLineCount: Int {
        max(0, bodyLines.count - bodyMaxLines)
    }

    var body: some View {
        HStack(spacing: 0) {
            MemoColorPalette.color(for: memo.colorName)
                .frame(width: stripWidth)
                .overlay(
                    Rectangle()
                        .fill(Color.ink)
                        .frame(width: 2),
                    alignment: .trailing
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.galBold14())
                    .foregroundColor(.ink)
                    .lineLimit(1)
                    .truncationMode(.tail)

                if !visibleBody.isEmpty {
                    Text(visibleBody)
                        .font(.galCondensed13())
                        .foregroundColor(.ink.opacity(0.85))
                        .lineLimit(bodyMaxLines)
                        .truncationMode(.tail)
                }

                if hiddenLineCount > 0 {
                    Text("+%d줄".localized(with: hiddenLineCount))
                        .font(.galBold10())
                        .foregroundColor(.shade)
                }

                HStack {
                    Text(memoListDateLabel(memo.createdAt))
                        .font(.pressStart8())
                        .foregroundColor(.ink.opacity(0.85))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(MemoColorPalette.color(for: memo.colorName))
                        .overlay(Rectangle().stroke(Color.ink.opacity(0.5), lineWidth: 1))
                    Spacer(minLength: 0)
                }
                .padding(.top, 2)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        // 상단 controlPanel(cream)과 명확히 분리되도록 panel(#FFF7E8) 사용.
        .background(Color.panel)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
    }
}

// MARK: - Shared Timestamp Stamp
private struct MemoTimestampStamp: View {
    let date: Date

    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing, spacing: 1) {
                Text(dateLabel)
                    .font(.pressStart8())
                Text(timeLabel)
                    .font(.pressStart8())
            }
            .foregroundColor(.ink.opacity(0.7))
            .padding(.horizontal, 5)
            .padding(.vertical, 3)
            .background(Color.panel)
            .overlay(Rectangle().stroke(Color.ink.opacity(0.4), lineWidth: 1))
            .fixedSize()
        }
    }

    private var dateLabel: String {
        let cal = Calendar.current
        return String(
            format: "%04d.%02d.%02d",
            cal.component(.year, from: date),
            cal.component(.month, from: date),
            cal.component(.day, from: date)
        )
    }

    private var timeLabel: String {
        let cal = Calendar.current
        return String(
            format: "%02d:%02d",
            cal.component(.hour, from: date),
            cal.component(.minute, from: date)
        )
    }
}

// 편집 화면 타이틀 + 리스트 셀에서 공유하는 날짜 표시 규칙.
// 오늘 작성 → "yyyy.MM.dd HH:mm", 이전 → "yyyy.MM.dd"
func memoListDateLabel(_ date: Date) -> String {
    let cal = Calendar.current
    let y = cal.component(.year, from: date)
    let m = cal.component(.month, from: date)
    let d = cal.component(.day, from: date)
    if cal.isDateInToday(date) {
        let h = cal.component(.hour, from: date)
        let mn = cal.component(.minute, from: date)
        return String(format: "%04d.%02d.%02d %02d:%02d", y, m, d, h, mn)
    }
    return String(format: "%04d.%02d.%02d", y, m, d)
}

private struct DogEarShape: Shape {
    let size: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: size, y: 0))
        path.addLine(to: CGPoint(x: size, y: size))
        path.closeSubpath()
        return path
    }
}

// MARK: - Memo Range Picker
// 기간 칩 → 단일 달력 popup. 첫 탭 = 시작, 두 번째 탭 = 끝 (시작보다 앞 날짜면 자동 swap).
// 두 날짜 모두 잡힌 상태에서 다시 탭하면 새 시작으로 리셋.
private struct MemoRangePicker: View {
    let initialFrom: Date
    let initialTo: Date
    let onApply: (Date, Date) -> Void
    let onClose: () -> Void

    @State private var pendingFrom: Date?
    @State private var pendingTo: Date?
    @State private var viewYear: Int
    @State private var viewMonth: Int

    init(
        initialFrom: Date,
        initialTo: Date,
        onApply: @escaping (Date, Date) -> Void,
        onClose: @escaping () -> Void
    ) {
        self.initialFrom = initialFrom
        self.initialTo = initialTo
        self.onApply = onApply
        self.onClose = onClose
        _pendingFrom = State(initialValue: initialFrom)
        _pendingTo = State(initialValue: initialTo)
        let cal = Calendar.current
        _viewYear  = State(initialValue: cal.component(.year, from: initialFrom))
        _viewMonth = State(initialValue: cal.component(.month, from: initialFrom))
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            popupCard
                .padding(.horizontal, 24)
        }
    }

    private var popupCard: some View {
        VStack(spacing: 0) {
            titleBar
            rangeLabelArea
            calendarSection
            applyButton
        }
        .background(Color.panel)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
    }

    private var titleBar: some View {
        HStack {
            Text("기간 설정")
                .font(.galBold13())
                .foregroundColor(.ink)
            Spacer()
            Button { onClose() } label: {
                Text("×")
                    .font(.pressStart10())
                    .foregroundColor(.ink)
                    .frame(width: 22, height: 22)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.sun)
        .overlay(
            Rectangle().fill(Color.ink).frame(height: 2),
            alignment: .bottom
        )
    }

    private var rangeLabelArea: some View {
        HStack(spacing: 8) {
            rangeLabel(title: "시작", date: pendingFrom)
            Text("~")
                .font(.galBold14())
                .foregroundColor(.ink)
            rangeLabel(title: "끝", date: pendingTo)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .overlay(
            Rectangle().fill(Color.ink.opacity(0.2)).frame(height: 1),
            alignment: .bottom
        )
    }

    private func rangeLabel(title: String, date: Date?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.localized())
                .font(.galBold9())
                .foregroundColor(.shade)
            Text(dateString(date))
                .font(.pressStart9())
                .foregroundColor(.ink)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.cream)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
    }

    private func dateString(_ date: Date?) -> String {
        guard let d = date else { return "----.--.--" }
        let cal = Calendar.current
        return String(
            format: "%04d.%02d.%02d",
            cal.component(.year, from: d),
            cal.component(.month, from: d),
            cal.component(.day, from: d)
        )
    }

    private var calendarSection: some View {
        VStack(spacing: 8) {
            monthNav
            weekdayHeader
            dayGrid
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
    }

    private var monthNav: some View {
        HStack(spacing: 0) {
            Button { prevMonth() } label: {
                Text("◀")
                    .font(.pressStart12())
                    .foregroundColor(.ink)
                    .frame(width: 44, height: 34)
                    .background(Color.cream)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
            }
            Text(String(format: "%d.%02d", viewYear, viewMonth))
                .font(.pressStart12())
                .foregroundColor(.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 34)
                .background(Color.panel)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
            Button { nextMonth() } label: {
                Text("▶")
                    .font(.pressStart12())
                    .foregroundColor(.ink)
                    .frame(width: 44, height: 34)
                    .background(Color.cream)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
            }
        }
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { i in
                Text(weekdayShort[i])
                    .font(.galBold11())
                    .foregroundColor(i == 0 ? .pixelRed : i == 6 ? .sky : .shade)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 2)
            }
        }
    }

    private var dayGrid: some View {
        let cols = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
        return LazyVGrid(columns: cols, spacing: 2) {
            ForEach(Array(cells.enumerated()), id: \.offset) { _, day in
                if let d = day {
                    RangeDayCell(
                        day: d,
                        isStart: isStart(d),
                        isEnd: isEnd(d),
                        isInRange: isInRange(d),
                        weekday: weekdayOf(day: d),
                        onTap: { selectDay(d) }
                    )
                } else {
                    Color.clear.frame(height: 36)
                }
            }
        }
    }

    private var applyButton: some View {
        Button {
            guard let from = pendingFrom, let to = pendingTo else { return }
            onApply(from, to)
        } label: {
            Text("APPLY")
                .font(.galBold14())
                .foregroundColor(canApply ? .ink : .shade)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(canApply ? Color.grass : Color.shade.opacity(0.1))
                .overlay(Rectangle().stroke(
                    canApply ? Color.ink : Color.shade.opacity(0.4),
                    lineWidth: 2
                ))
        }
        .disabled(!canApply)
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }

    private var canApply: Bool {
        pendingFrom != nil && pendingTo != nil
    }

    // MARK: helpers
    private var weekdayShort: [String] {
        var cal = Calendar.current
        cal.locale = Locale.current
        let symbols = cal.veryShortStandaloneWeekdaySymbols
        return symbols.count == 7 ? symbols : ["S", "M", "T", "W", "T", "F", "S"]
    }

    private var cells: [Int?] {
        var comps = DateComponents()
        comps.year = viewYear; comps.month = viewMonth; comps.day = 1
        guard let first = Calendar.current.date(from: comps) else { return [] }
        let offset = Calendar.current.component(.weekday, from: first) - 1
        let daysCount = Calendar.current.range(of: .day, in: .month, for: first)!.count
        return Array(repeating: nil, count: offset) + (1...daysCount).map { Optional($0) }
    }

    private func weekdayOf(day: Int) -> Int {
        guard let date = dateFor(day: day) else { return 0 }
        return Calendar.current.component(.weekday, from: date) - 1
    }

    private func dateFor(day: Int) -> Date? {
        var comps = DateComponents()
        comps.year = viewYear; comps.month = viewMonth; comps.day = day
        return Calendar.current.date(from: comps)
    }

    private func sameDay(_ a: Date?, _ b: Date?) -> Bool {
        guard let a = a, let b = b else { return false }
        return Calendar.current.isDate(a, inSameDayAs: b)
    }

    private func isStart(_ day: Int) -> Bool {
        sameDay(dateFor(day: day), pendingFrom)
    }

    private func isEnd(_ day: Int) -> Bool {
        sameDay(dateFor(day: day), pendingTo)
    }

    private func isInRange(_ day: Int) -> Bool {
        guard let from = pendingFrom, let to = pendingTo, let d = dateFor(day: day) else { return false }
        let cal = Calendar.current
        let f = cal.startOfDay(for: from)
        let t = cal.startOfDay(for: to)
        let x = cal.startOfDay(for: d)
        return x >= f && x <= t
    }

    private func selectDay(_ day: Int) {
        guard let date = dateFor(day: day) else { return }
        if pendingFrom == nil {
            pendingFrom = date
        } else if pendingTo == nil {
            if let from = pendingFrom,
               Calendar.current.startOfDay(for: date) < Calendar.current.startOfDay(for: from) {
                pendingTo = from
                pendingFrom = date
            } else {
                pendingTo = date
            }
        } else {
            pendingFrom = date
            pendingTo = nil
        }
    }

    private func prevMonth() {
        if viewMonth == 1 { viewYear -= 1; viewMonth = 12 } else { viewMonth -= 1 }
    }

    private func nextMonth() {
        if viewMonth == 12 { viewYear += 1; viewMonth = 1 } else { viewMonth += 1 }
    }
}

private struct RangeDayCell: View {
    let day: Int
    let isStart: Bool
    let isEnd: Bool
    let isInRange: Bool
    let weekday: Int
    let onTap: () -> Void

    private var isEndpoint: Bool { isStart || isEnd }

    private var bgColor: Color {
        if isEndpoint { return .peach }
        if isInRange { return Color.peach.opacity(0.3) }
        return .white
    }

    private var borderColor: Color {
        if isEndpoint { return .peachDk }
        if isInRange { return .ink.opacity(0.3) }
        return .ink
    }

    private var borderWidth: CGFloat { isEndpoint ? 2.5 : 1.5 }

    private var dayColor: Color {
        if isEndpoint { return .ink }
        switch weekday {
        case 0: return .redDk
        case 6: return Color(hex: "#3A7FC1")
        default: return .ink
        }
    }

    var body: some View {
        Button(action: onTap) {
            Text(String(format: "%02d", day))
                .font(.pressStart9())
                .foregroundColor(dayColor)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(bgColor)
                .overlay(Rectangle().stroke(borderColor, lineWidth: borderWidth))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Memo Color Palette
enum MemoColorPalette {
    struct Item {
        let name: String
        let color: Color
    }

    static let all: [Item] = [
        Item(name: "yellow",   color: Color(hex: "#FFF59D")),
        Item(name: "pink",     color: Color(hex: "#F8BBD9")),
        Item(name: "mint",     color: Color(hex: "#B2DFDB")),
        Item(name: "lavender", color: Color(hex: "#E1BEE7")),
        Item(name: "peach",    color: Color(hex: "#FFCCBC")),
        Item(name: "sky",      color: Color(hex: "#B3E5FC")),
    ]

    static func color(for name: String) -> Color {
        all.first { $0.name == name }?.color ?? Color(hex: "#FFF59D")
    }
}
