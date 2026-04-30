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
        .sheet(isPresented: $viewModel.isCreatePresented) {
            MemoCreateView(viewModel: viewModel)
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
            Text("메모장")
                .font(.galBold22())
                .foregroundColor(.ink)
            Spacer()
            Button {
                viewModel.presentCreate()
            } label: {
                HStack(spacing: 4) {
                    Text("+")
                        .font(.pressStart12())
                    Text("메모 작성")
                        .font(.galBold14())
                }
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
            PixelArtView(grid: PixelArtAssets.mascotGrid, palette: PixelArtAssets.mascotPalette, scale: 3)
            Text("메모가 없어요!")
                .font(.galBold16())
                .foregroundColor(.shade)
            Text("+ 메모 작성으로 추가해보세요")
                .font(.pressStart7())
                .foregroundColor(.shade.opacity(0.7))
        }
    }
}

// MARK: - Memo Card (dog-ear style)
private struct MemoCardView: View {
    let memo: MemoEntity
    private let cornerSize: CGFloat = 18

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Card body
            VStack(alignment: .leading, spacing: 0) {
                Text(memo.isWritten ? memo.note : "...")
                    .font(.galBold14())
                    .foregroundColor(.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                // Dot separator + date
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.ink.opacity(0.3))
                        .frame(width: 3, height: 3)
                    Circle()
                        .fill(Color.ink.opacity(0.3))
                        .frame(width: 3, height: 3)
                    Circle()
                        .fill(Color.ink.opacity(0.3))
                        .frame(width: 3, height: 3)
                    Spacer()
                    Text(memoDateLabel)
                        .font(.pressStart7())
                        .foregroundColor(.shade)
                }
                .padding(.top, 8)
            }
            .padding(10)
            .padding(.trailing, cornerSize - 4)
            .background(MemoColorPalette.color(for: memo.colorName))
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))

            // Dog-ear triangle (top-right)
            DogEarShape(size: cornerSize)
                .fill(Color.ink.opacity(0.25))
                .frame(width: cornerSize, height: cornerSize)
        }
    }

    private var memoDateLabel: String {
        let cal = Calendar.current
        let m = cal.component(.month, from: memo.targetDate)
        let d = cal.component(.day, from: memo.targetDate)
        return String(format: "%02d/%02d", m, d)
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
