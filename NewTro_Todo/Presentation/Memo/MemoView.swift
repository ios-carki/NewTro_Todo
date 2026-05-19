import SwiftUI

struct MemoView: View {
    @ObservedObject var viewModel: MemoViewModel
    @State private var isRangeExpanded: Bool = false
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
            if viewModel.isCreatePresented {
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

    // MARK: - Control Panel (filter + sort + range)
    private var controlPanel: some View {
        VStack(spacing: 8) {
            filterRow
            sortRow
            viewModeRow
            if isRangeExpanded {
                rangeRow
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
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
            withAnimation(.easeInOut(duration: 0.2)) {
                isRangeExpanded = false
            }
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
            withAnimation(.easeInOut(duration: 0.2)) {
                isRangeExpanded.toggle()
            }
        } label: {
            HStack(spacing: 3) {
                Text("기간")
                Text(isRangeExpanded ? "▲" : "▼")
                    .font(.system(size: 8))
            }
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

    // MARK: - Range Row (inline fold-out)
    private var rangeRow: some View {
        HStack(spacing: 6) {
            DatePicker("", selection: $viewModel.rangeFrom, displayedComponents: .date)
                .labelsHidden()
                .tint(.ink)

            Text("~")
                .font(.galBold11())
                .foregroundColor(.ink)

            DatePicker("", selection: $viewModel.rangeTo, displayedComponents: .date)
                .labelsHidden()
                .tint(.ink)

            Spacer()

            Button {
                viewModel.applyRangeFilter()
            } label: {
                Text("APPLY")
                    .font(.galBold11())
                    .foregroundColor(.cream)
                    .padding(.horizontal, 8)
                    .frame(height: 26)
                    .background(Color.grass)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
                    .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
            }
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
        .background(Color.cream)
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
            .background(Color.ink.opacity(0.06))
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
