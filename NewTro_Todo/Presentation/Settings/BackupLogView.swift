import SwiftUI

struct BackupLogView: View {
    @ObservedObject var viewModel: BackupLogViewModel
    @Environment(\.dismiss) private var dismiss
    let onShowRangePicker: () -> Void

    var body: some View {
        ZStack {
            // 탭바가 없는 모달이라 흙 영역을 한 단 줄여 어색함 완화.
            BackgroundSceneryView(groundHeight: TabSceneLayout.modalGroundHeight)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                retentionNotice
                    .padding(.horizontal, 14)
                    .padding(.top, 8)

                filterBar
                    .padding(.horizontal, 14)
                    .padding(.top, 8)

                sortBar
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
                    .padding(.bottom, 6)

                if viewModel.isEmpty {
                    emptyState
                } else {
                    logList
                }
            }
        }
        .navigationTitle("백업 로그")
        .navigationBarTitleDisplayMode(.inline)
        // 네비바 배경을 배경화면 상단과 같은 하늘색(.sky)으로 채움. 투명일 때 스크롤 콘텐츠가
        // 네비 영역에 비치던 문제 해결.
        .toolbarBackground(Color.sky, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                closeButton
            }
            // 전역 네비 타이틀 색(inkC) 대신 이 화면은 검은색으로 직접 렌더.
            ToolbarItem(placement: .principal) {
                Text("백업 로그")
                    .font(.galBold17())
                    .foregroundColor(.black)
            }
        }
        .onAppear { viewModel.onAppear() }
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            PixelArtView(
                grid: PixelArtAssets.dotXGrid,
                palette: PixelArtAssets.dotXPalette,
                scale: 2
            )
            .frame(width: 32, height: 32)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("닫기"))
    }

    // MARK: - Retention Notice

    private var retentionNotice: some View {
        HStack(spacing: 6) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 11))
                .foregroundColor(.shade)
            Text("최근 30개 로그만 보여집니다")
                .font(.galBold11())
                .foregroundColor(.shade)
            Spacer()
        }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                filterChip(.all)
                filterChip(.today)
                filterChip(.last7Days)
                filterChip(.last30Days)
                filterChip(.custom(from: Date(), to: Date()))
            }
            .padding(.vertical, 2)
        }
    }

    private func filterChip(_ candidate: BackupLogViewModel.Filter) -> some View {
        let isActive = isCurrentFilter(candidate)
        return Button {
            viewModel.selectFilter(candidate)
            if case .custom = candidate {
                onShowRangePicker()
            }
        } label: {
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color.ink)
                    .padding(.leading, 2)
                    .padding(.top, 2)

                Text(LocalizedStringKey(candidate.titleKey))
                    .font(.galBold10())
                    .foregroundColor(.ink)
                    .padding(.horizontal, 10)
                    .frame(height: 26)
                    .background(isActive ? Color.sun : Color.cream)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                    .padding(.trailing, 2)
                    .padding(.bottom, 2)
            }
            .fixedSize()
        }
        .buttonStyle(.plain)
    }

    private func isCurrentFilter(_ candidate: BackupLogViewModel.Filter) -> Bool {
        switch (viewModel.filter, candidate) {
        case (.all, .all),
             (.today, .today),
             (.last7Days, .last7Days),
             (.last30Days, .last30Days):
            return true
        case (.custom, .custom):
            return true
        default:
            return false
        }
    }

    // MARK: - Sort Bar

    private var sortBar: some View {
        HStack(spacing: 8) {
            Button {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.7)) {
                    viewModel.toggleSortOrder()
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.ink)
                        .rotationEffect(.degrees(viewModel.sortOrder == .newest ? 0 : 180))
                    Text(LocalizedStringKey(viewModel.sortOrder.titleKey))
                        .font(.galBold11())
                        .foregroundColor(.ink)
                        .id(viewModel.sortOrder)
                        .transition(.opacity)
                }
                .padding(.horizontal, 10)
                .frame(height: 26)
                .background(Color.cream)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            if case let .custom(from, to) = viewModel.filter {
                Text(customRangeLabel(from: from, to: to))
                    .font(.pressStart9())
                    .foregroundColor(.shade)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
    }

    private func customRangeLabel(from: Date, to: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "yyyy-MM-dd"
        return "\(f.string(from: from)) ~ \(f.string(from: to))"
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            PixelPanel(bg: .cream, padding: 16) {
                VStack(spacing: 10) {
                    PixelArtView(
                        grid: emptyChestGrid,
                        palette: emptyChestPalette,
                        scale: 5
                    )
                    Text("데이터 백업 로그가 없어요")
                        .font(.galBold14())
                        .foregroundColor(.ink)
                    Text("설정에서 데이터를 백업해보세요!")
                        .font(.galBold11())
                        .foregroundColor(.shade.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
            .padding(.top, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Log List

    private var logList: some View {
        ScrollView {
            LazyVStack(spacing: 12, pinnedViews: []) {
                ForEach(viewModel.sections) { section in
                    sectionView(section)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)
            .padding(.bottom, TabSceneLayout.contentBottomMargin)
        }
        .clipAboveGround(groundHeight: TabSceneLayout.modalGroundHeight)
    }

    private func sectionView(_ section: BackupLogViewModel.Section) -> some View {
        VStack(spacing: 0) {
            sectionHeader(section.date)
                .padding(.bottom, 6)

            VStack(spacing: 0) {
                ForEach(Array(section.entries.enumerated()), id: \.element.id) { idx, entry in
                    logRow(entry: entry)
                    if idx < section.entries.count - 1 {
                        Divider()
                            .background(Color.ink.opacity(0.2))
                            .padding(.horizontal, 14)
                    }
                }
            }
            .background(Color.white)
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
        }
    }

    private func sectionHeader(_ date: Date) -> some View {
        HStack(spacing: 6) {
            Rectangle()
                .fill(Color.ink)
                .frame(width: 6, height: 6)
            Text(formatSectionDate(date))
                .font(.galBold11())
                .foregroundColor(.ink)
            Spacer()
        }
        .padding(.leading, 2)
    }

    private func logRow(entry: BackupLogEntry) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "externaldrive.badge.checkmark")
                .font(.system(size: 13))
                .foregroundColor(.grass)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 4) {
                Text("데이터 백업")
                    .font(.galBold13())
                    .foregroundColor(.ink)
                Text(countsLine(entry.counts))
                    .font(.galBold10())
                    .foregroundColor(.shade)
            }

            Spacer()

            Text(formatTime(entry.createdAt))
                .font(.pressStart9())
                .foregroundColor(.sun)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    // MARK: - Formatting

    private func formatSectionDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy-MM-dd"
        let base = formatter.string(from: date)
        let wf = DateFormatter()
        wf.locale = Locale.current
        wf.dateFormat = "EEE"
        return "\(base)  \(wf.string(from: date))"
    }

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    private func countsLine(_ c: BackupCounts) -> String {
        let template = "할일 %d · 메모 %d · 템플릿 %d".localized()
        return String(format: template, c.todo, c.quickNote, c.template)
    }
}

// MARK: - Cover Wrapper
// fullScreenCover 안에서 NavigationView 를 감싸 dim+팝업이 nav bar 위에 오버레이되도록 하는 컨테이너.
// 팝업 상태와 VM 을 여기서 소유하고 자식에 ObservedObject + 콜백으로 내려줌.
struct BackupLogCover: View {
    @StateObject private var viewModel: BackupLogViewModel
    @State private var showRangePicker = false

    init(makeVM: @escaping @MainActor () -> BackupLogViewModel) {
        _viewModel = StateObject(wrappedValue: makeVM())
    }

    var body: some View {
        NavigationView {
            BackupLogView(
                viewModel: viewModel,
                onShowRangePicker: { showRangePicker = true }
            )
        }
        .navigationViewStyle(.stack)
        .overlay {
            if showRangePicker {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { showRangePicker = false }

                    PixelDateRangePopup(
                        initialFrom: viewModel.customFrom,
                        initialTo: viewModel.customTo,
                        onApply: { from, to in
                            viewModel.customFrom = from
                            viewModel.customTo = to
                            viewModel.confirmCustomRange()
                            showRangePicker = false
                        },
                        onClose: { showRangePicker = false }
                    )
                    .padding(.horizontal, 24)
                }
            }
        }
    }
}

// MARK: - Empty Chest Pixel Art

private let emptyChestGrid: [String] = [
    "................",
    ".....11111111...",
    "....1........1..",
    "...1..........1.",
    "..11111111111111",
    "..1...22222...1.",
    "..1...23332...1.",
    "..1...22222...1.",
    "..11111111111111",
    "..1...........1.",
    "..1...........1.",
    "..11111111111111",
    "................",
    "................"
]

private let emptyChestPalette: [Character: Color] = [
    "1": .ink,
    "2": .peach,
    "3": .sun
]
