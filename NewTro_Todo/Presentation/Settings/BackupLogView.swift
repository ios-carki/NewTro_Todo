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
        }
        .navigationTitle("백업 로그")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.onAppear() }
        .sheet(isPresented: $viewModel.showCustomRangePicker) {
            if #available(iOS 16.0, *) {
                customRangeSheet
                    .presentationDetents([.medium])
            } else {
                customRangeSheet
            }
        }
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
                    .font(.pressStart7())
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
            if case let .custom(from, to) = viewModel.filter {
                Text(customRangeLabel(from: from, to: to))
                    .font(.pressStart7())
                    .foregroundColor(.shade)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer(minLength: 0)

            Button {
                viewModel.toggleSortOrder()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: viewModel.sortOrder == .newest
                          ? "arrow.down" : "arrow.up")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.ink)
                    Text(LocalizedStringKey(viewModel.sortOrder.titleKey))
                        .font(.galBold13())
                        .foregroundColor(.ink)
                }
                .padding(.horizontal, 10)
                .frame(height: 26)
                .background(Color.cream)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
            }
            .buttonStyle(.plain)
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
                .font(.pressStart8())
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
                    .font(.pressStart7())
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

    // MARK: - Custom Range Sheet

    private var customRangeSheet: some View {
        ZStack {
            Color.panel.ignoresSafeArea()
            VStack(spacing: 18) {
                Text("기간 선택")
                    .font(.galBold17())
                    .foregroundColor(.ink)
                    .padding(.top, 18)

                VStack(spacing: 10) {
                    rangeDatePickerRow(title: "시작", date: $viewModel.customFrom)
                    rangeDatePickerRow(title: "끝", date: $viewModel.customTo)
                }
                .padding(14)
                .background(Color.white)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
                .padding(.horizontal, 18)

                Spacer()

                HStack(spacing: 10) {
                    Button { viewModel.cancelCustomRange() } label: {
                        Text("취소")
                            .font(.galBold14())
                            .foregroundColor(.ink)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(Color.tile)
                            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                            .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
                    }
                    .buttonStyle(.plain)

                    Button { viewModel.confirmCustomRange() } label: {
                        Text("확인")
                            .font(.galBold14())
                            .foregroundColor(.ink)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(Color.peach)
                            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                            .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.customFrom > viewModel.customTo)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 18)
            }
        }
    }

    private func rangeDatePickerRow(title: LocalizedStringKey, date: Binding<Date>) -> some View {
        HStack {
            Text(title)
                .font(.galBold14())
                .foregroundColor(.ink)
                .frame(width: 40, alignment: .leading)
            Spacer()
            DatePicker("", selection: date, displayedComponents: .date)
                .labelsHidden()
        }
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
