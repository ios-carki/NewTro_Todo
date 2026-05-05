import SwiftUI

struct MemoView: View {
    @ObservedObject var viewModel: MemoViewModel
    @State private var isRangeExpanded: Bool = false
    @AppStorage("selectedCharacterId") private var selectedCharacterId: String = "pinko"
    private let tabBarHeight: CGFloat = 113

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
            Text(type.rawValue)
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

    // MARK: - Masonry Grid
    private var memoGrid: some View {
        ScrollView {
            if viewModel.displayedMemos.isEmpty {
                emptyState.padding(.top, 60)
            } else {
                masonryColumns
                    .padding(.horizontal, 16)
                    .padding(.bottom, tabBarHeight + 16)
            }
        }
    }

    private var masonryColumns: some View {
        let memos = viewModel.displayedMemos
        let leftMemos = memos.enumerated().filter { $0.offset % 2 == 0 }.map(\.element)
        let rightMemos = memos.enumerated().filter { $0.offset % 2 == 1 }.map(\.element)

        return HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 12) {
                ForEach(leftMemos) { memo in
                    MemoCardView(memo: memo)
                        .onTapGesture { viewModel.openMemo(memo) }
                }
            }
            VStack(spacing: 12) {
                ForEach(rightMemos) { memo in
                    MemoCardView(memo: memo)
                        .onTapGesture { viewModel.openMemo(memo) }
                }
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

// MARK: - Memo Card (dog-ear style)
private struct MemoCardView: View {
    let memo: MemoEntity
    private let cornerSize: CGFloat = 18

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                Text(memo.isWritten ? memo.note : "...")
                    .font(.galCondensed13())
                    .foregroundColor(.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                timestampStamp
                    .padding(.top, 8)
            }
            .padding(10)
            .padding(.trailing, cornerSize - 4)
            .background(MemoColorPalette.color(for: memo.colorName))
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))

            DogEarShape(size: cornerSize)
                .fill(Color.ink.opacity(0.25))
                .frame(width: cornerSize, height: cornerSize)
        }
    }

    // MARK: - Timestamp Stamp
    private var timestampStamp: some View {
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
        let y = cal.component(.year, from: memo.createdAt)
        let m = cal.component(.month, from: memo.createdAt)
        let d = cal.component(.day, from: memo.createdAt)
        return String(format: "%04d.%02d.%02d", y, m, d)
    }

    private var timeLabel: String {
        let cal = Calendar.current
        let h = cal.component(.hour, from: memo.createdAt)
        let mn = cal.component(.minute, from: memo.createdAt)
        return String(format: "%02d:%02d", h, mn)
    }
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
