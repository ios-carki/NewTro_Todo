import SwiftUI

struct DatePickerSheetView: View {
    let initialDate: Date
    let monthOverviewProvider: (Int, Int) async -> [Int: DayContent]
    let dayStatsProvider: (Date) async -> DayPreviewStats
    let onDateConfirmed: (Date) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate: Date
    @State private var dayStats: DayPreviewStats? = nil
    @State private var statsLoadId: UUID = UUID()

    init(
        initialDate: Date,
        monthOverviewProvider: @escaping (Int, Int) async -> [Int: DayContent],
        dayStatsProvider: @escaping (Date) async -> DayPreviewStats,
        onDateConfirmed: @escaping (Date) -> Void
    ) {
        self.initialDate = initialDate
        self.monthOverviewProvider = monthOverviewProvider
        self.dayStatsProvider = dayStatsProvider
        self.onDateConfirmed = onDateConfirmed
        _selectedDate = State(initialValue: initialDate)
    }

    var body: some View {
        ZStack {
            Color.panel.ignoresSafeArea()

            VStack(spacing: 0) {
                Text("날짜 이동")
                    .font(.galBold16())
                    .foregroundColor(.ink)
                    .padding(.top, 16)
                    .padding(.bottom, 14)

                PixelCalendarPicker(
                    initialDate: initialDate,
                    externalDate: selectedDate,
                    monthOverviewProvider: monthOverviewProvider,
                    onDateSelected: { date in
                        selectedDate = date
                        loadStats(for: date)
                    }
                )
                .padding(.top, 4)

                previewCard(date: selectedDate)
                    .padding(.horizontal, 14)
                    .padding(.top, 16)

                Spacer(minLength: 12)

                navigateButton
                    .padding(.horizontal, 14)
                    .padding(.bottom, 20)
            }
        }
        .onAppear { loadStats(for: selectedDate) }
    }

    // MARK: - Preview Card

    private func previewCard(date: Date) -> some View {
        PixelPanel(bg: .cream, padding: 14) {
            VStack(alignment: .leading, spacing: 10) {
                Text(formattedHeader(date))
                    .font(.galBold14())
                    .foregroundColor(.ink)

                if let stats = dayStats {
                    statsGrid(stats: stats)
                } else {
                    Text("불러오는 중…")
                        .font(.galBold11())
                        .foregroundColor(.shade.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func statsGrid(stats: DayPreviewStats) -> some View {
        HStack(spacing: 8) {
            statChip(label: "할 일 수", value: stats.totalTodos, accent: .ink)
            statChip(label: "완료", value: stats.completedTodos, accent: .grassDk)
            statChip(label: "미완료", value: stats.incompleteTodos, accent: .pinkDk)
            statChip(label: "메모", value: stats.memoCount, accent: .peachDk)
        }
    }

    private func statChip(label: LocalizedStringKey, value: Int, accent: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.galBold10())
                .foregroundColor(.shade)
            Text("\(value)")
                .font(.pressStart12())
                .foregroundColor(accent)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(Color.panel)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
    }

    // MARK: - Navigate Button

    private var navigateButton: some View {
        Button {
            onDateConfirmed(selectedDate)
            dismiss()
        } label: {
            Text(navigateLabel)
                .font(.galBold14())
                .foregroundColor(.cream)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.peachDk)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
        }
    }

    private var navigateLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .long
        return "%@로 이동".localized(with: formatter.string(from: selectedDate))
    }

    private func formattedHeader(_ d: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        return "%@ 요약".localized(with: formatter.string(from: d))
    }

    // MARK: - Stats Loading

    private func loadStats(for date: Date) {
        let token = UUID()
        statsLoadId = token
        dayStats = nil
        Task {
            let result = await dayStatsProvider(date)
            await MainActor.run {
                guard token == statsLoadId else { return }
                dayStats = result
            }
        }
    }
}
