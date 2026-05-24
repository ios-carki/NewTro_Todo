import SwiftUI

struct BackupLogView: View {
    @StateObject private var viewModel: BackupLogViewModel

    // iOS 15 NavigationLink는 destination을 eagerly 평가하므로 autoclosure 로 lazy 초기화.
    init(viewModel: @autoclosure @escaping () -> BackupLogViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ZStack {
            Color.sky.ignoresSafeArea()

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

            if viewModel.showCustomRangePicker {
                PixelDateRangePopup(
                    initialFrom: viewModel.customFrom,
                    initialTo: viewModel.customTo,
                    onApply: { from, to in
                        viewModel.customFrom = from
                        viewModel.customTo = to
                        viewModel.confirmCustomRange()
                    },
                    onClose: { viewModel.cancelCustomRange() }
                )
            }
        }
        .navigationTitle("백업 로그")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.onAppear() }
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
        VStack(spacing: 14) {
            Spacer()
            PixelArtView(
                grid: emptyChestGrid,
                palette: emptyChestPalette,
                scale: 5
            )
            Text("데이터 백업 로그가 없어요")
                .font(.galBold14())
                .foregroundColor(.shade)
            Spacer()
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
            .padding(.bottom, 80)
        }
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
