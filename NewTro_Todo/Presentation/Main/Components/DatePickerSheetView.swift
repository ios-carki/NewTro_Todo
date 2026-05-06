import SwiftUI

struct DatePickerSheetView: View {
    let monthOverviewProvider: (Int, Int) async -> [Int: DayContent]
    let dayStatsProvider: (Date) async -> DayPreviewStats
    let onDateConfirmed: (Date) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate: Date? = nil
    @State private var dayStats: DayPreviewStats? = nil
    @State private var statsLoadId: UUID = UUID()

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
                    externalDate: selectedDate,
                    monthOverviewProvider: monthOverviewProvider,
                    onDateSelected: { date in
                        selectedDate = date
                        loadStats(for: date)
                    }
                )
                .padding(.top, 4)

                previewArea
                    .padding(.horizontal, 14)
                    .padding(.top, 16)

                Spacer(minLength: 12)

                navigateButton
                    .padding(.horizontal, 14)
                    .padding(.bottom, 20)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Preview Card

    @ViewBuilder
    private var previewArea: some View {
        if let date = selectedDate {
            previewCard(date: date)
        } else {
            placeholderCard
        }
    }

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
            statChip(label: "총", value: stats.totalTodos, accent: .ink)
            statChip(label: "완료", value: stats.completedTodos, accent: .grassDk)
            statChip(label: "미완료", value: stats.incompleteTodos, accent: .pinkDk)
            statChip(label: "메모", value: stats.memoCount, accent: .peachDk)
        }
    }

    private func statChip(label: String, value: Int, accent: Color) -> some View {
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

    private var placeholderCard: some View {
        PixelPanel(bg: .cream, padding: 14) {
            Text("이동할 날짜를 선택해주세요")
                .font(.galBold11())
                .foregroundColor(.shade.opacity(0.7))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
        }
    }

    // MARK: - Navigate Button

    private var navigateButton: some View {
        Button {
            guard let date = selectedDate else { return }
            onDateConfirmed(date)
            dismiss()
        } label: {
            Text(navigateLabel)
                .font(.galBold14())
                .foregroundColor(selectedDate == nil ? .shade.opacity(0.6) : .cream)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(selectedDate == nil ? Color.panel : Color.peachDk)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
        }
        .disabled(selectedDate == nil)
    }

    private var navigateLabel: String {
        guard let d = selectedDate else { return "날짜를 선택해주세요" }
        let cal = Calendar.current
        let y = cal.component(.year, from: d)
        let m = cal.component(.month, from: d)
        let day = cal.component(.day, from: d)
        return "\(y)년 \(m)월 \(day)일로 이동"
    }

    private func formattedHeader(_ d: Date) -> String {
        let cal = Calendar.current
        let y = cal.component(.year, from: d)
        let m = cal.component(.month, from: d)
        let day = cal.component(.day, from: d)
        return String(format: "%04d.%02d.%02d 요약", y, m, day)
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
