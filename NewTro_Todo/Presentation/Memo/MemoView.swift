import SwiftUI

struct MemoView: View {
    @ObservedObject var viewModel: MemoViewModel
    private let tabBarHeight: CGFloat = 113

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.top, 8)

            filterBar
                .padding(.horizontal, 16)
                .padding(.top, 8)

            sortBar
                .padding(.horizontal, 16)
                .padding(.top, 6)

            memoGrid
                .padding(.top, 8)
        }
        .sheet(isPresented: $viewModel.isFormPresented) {
            if let memo = viewModel.editingMemo {
                MemoFormView(memo: memo, viewModel: viewModel)
            }
        }
        .sheet(isPresented: $viewModel.isRangePickerPresented) {
            MemoRangePickerView(viewModel: viewModel)
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
            Text("MEMO")
                .font(.pressStart12())
                .foregroundColor(.ink)
            Spacer()
            Button {
                viewModel.addMemo()
            } label: {
                Text("+")
                    .font(.pressStart12())
                    .foregroundColor(.ink)
                    .frame(width: 34, height: 34)
                    .background(Color.peach)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                    .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: - Filter Bar
    private var filterBar: some View {
        HStack(spacing: 6) {
            filterChip(.all)
            filterChip(.today)
            filterChip(.days(7))
            filterChip(.days(30))
            rangeChip
        }
    }

    private func filterChip(_ filter: MemoFilter) -> some View {
        let isActive = viewModel.filterType == filter
        return Button { viewModel.selectFilter(filter) } label: {
            Text(filter.label)
                .font(.pressStart7())
                .foregroundColor(isActive ? .cream : .ink)
                .padding(.horizontal, 8)
                .frame(height: 26)
                .background(isActive ? Color.ink : Color.panel)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
        }
    }

    private var rangeChip: some View {
        let isActive = viewModel.isRangeFilterActive
        return Button { viewModel.selectFilter(.range(from: viewModel.rangeFrom, to: viewModel.rangeTo)) } label: {
            Text("기간")
                .font(.pressStart7())
                .foregroundColor(isActive ? .cream : .ink)
                .padding(.horizontal, 8)
                .frame(height: 26)
                .background(isActive ? Color.ink : Color.panel)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
        }
    }

    // MARK: - Sort Bar
    private var sortBar: some View {
        HStack {
            Text("\(viewModel.memos.count)개")
                .font(.pressStart7())
                .foregroundColor(.shade)
            Spacer()
            HStack(spacing: 10) {
                ForEach(MemoSortType.allCases, id: \.self) { sort in
                    Button { viewModel.sortType = sort } label: {
                        Text(sort.rawValue)
                            .font(.pressStart7())
                            .foregroundColor(viewModel.sortType == sort ? .ink : .shade.opacity(0.6))
                            .underline(viewModel.sortType == sort)
                    }
                }
            }
        }
    }

    // MARK: - Grid
    private var memoGrid: some View {
        ScrollView {
            if viewModel.displayedMemos.isEmpty {
                emptyState.padding(.top, 60)
            } else {
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 12
                ) {
                    ForEach(viewModel.displayedMemos) { memo in
                        MemoCardView(memo: memo)
                            .onTapGesture { viewModel.openMemo(memo) }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, tabBarHeight + 16)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            PixelArtView(grid: PixelArtAssets.mascotGrid, palette: PixelArtAssets.mascotPalette, scale: 3)
            Text("메모가 없어요!")
                .font(.galBold16())
                .foregroundColor(.shade)
            Text("+ 버튼으로 추가해보세요")
                .font(.pressStart7())
                .foregroundColor(.shade.opacity(0.7))
        }
    }
}

// MARK: - Memo Card
private struct MemoCardView: View {
    let memo: MemoEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(memoDateLabel)
                .font(.pressStart7())
                .foregroundColor(.shade)
                .lineLimit(1)

            Text(memo.isWritten ? memo.note : "...")
                .font(.galBold14())
                .foregroundColor(.ink)
                .lineLimit(4)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(height: 110)
        .background(MemoColorPalette.color(for: memo.colorName))
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
    }

    private var memoDateLabel: String {
        let cal = Calendar.current
        let m = cal.component(.month, from: memo.targetDate)
        let d = cal.component(.day, from: memo.targetDate)
        return String(format: "%02d/%02d", m, d)
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
