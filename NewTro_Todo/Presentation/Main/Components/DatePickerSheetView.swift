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
    @State private var showWheelPicker: Bool = false
    @State private var wheelDate: Date = Date()

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
                    onHeaderTap: {
                        wheelDate = selectedDate
                        showWheelPicker = true
                    },
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

                bottomNavBar
                    .padding(.horizontal, 14)
                    .padding(.bottom, 20)
            }

            if showWheelPicker {
                wheelPickerOverlay
            }
        }
        .onAppear { loadStats(for: selectedDate) }
    }

    // MARK: - Wheel Picker Overlay

    private var wheelPickerOverlay: some View {
        ZStack {
            Color.ink.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { showWheelPicker = false }

            PixelPanel(bg: .cream, padding: 16) {
                VStack(spacing: 14) {
                    Text("날짜 선택")
                        .font(.galBold14())
                        .foregroundColor(.ink)

                    PixelDateWheel(date: $wheelDate, mode: .date)

                    HStack(spacing: 10) {
                        Button { showWheelPicker = false } label: {
                            Text("취소")
                                .font(.galBold13())
                                .foregroundColor(.ink)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.panel)
                                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                        }
                        Button {
                            selectedDate = wheelDate
                            loadStats(for: wheelDate)
                            showWheelPicker = false
                        } label: {
                            Text("선택")
                                .font(.galBold13())
                                .foregroundColor(.cream)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.peachDk)
                                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 28)
        }
        .transition(.opacity)
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

    // MARK: - Bottom Nav Bar (오늘로 이동 / 선택 날짜 이동)

    private var isSelectedToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    private var bottomNavBar: some View {
        HStack(spacing: 10) {
            todayButton
            specificDateButton
        }
    }

    private var todayButton: some View {
        // 버튼 동작: 캘린더의 selectedDate 를 오늘로 변경(시트 안에서만). 실제 이동은 우측 버튼.
        // 비활성 조건: selectedDate 가 이미 오늘인 경우.
        Button {
            let today = Calendar.current.startOfDay(for: Date())
            selectedDate = today
            loadStats(for: today)
        } label: {
            Text("오늘")
                .font(.galBold13())
                .foregroundColor(.ink)
                .opacity(isSelectedToday ? 0.3 : 1)
                .frame(width: 80, height: 48)
                .background(Color.cream)
                .overlay(Rectangle().stroke(isSelectedToday ? Color.ink.opacity(0.25) : Color.ink, lineWidth: 2))
                .background(
                    Rectangle()
                        .fill(Color.ink)
                        .offset(x: 3, y: 3)
                        .opacity(isSelectedToday ? 0 : 1)
                )
        }
        .disabled(isSelectedToday)
    }

    private var specificDateButton: some View {
        Button {
            onDateConfirmed(selectedDate)
            dismiss()
        } label: {
            Text(specificDateLabel)
                .font(.galBold13())
                .foregroundColor(.cream)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.peachDk)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
        }
    }

    private var specificDateLabel: String {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month, .day], from: selectedDate)
        return "\(comps.year ?? 0)년 \(comps.month ?? 0)월 \(comps.day ?? 0)일로 이동"
    }

    private func formattedHeader(_ d: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        return "%@ 요약".localized(with: formatter.string(from: d))
    }

    // MARK: - Stats Loading

    private func loadStats(for date: Date) {
        // 직전 날짜 stats를 유지한 채 새 결과 도착 시 교체.
        // dayStats = nil 로 비우면 카드가 "불러오는 중…" 텍스트 높이로 줄었다 다시 커지는 점멸이 발생.
        let token = UUID()
        statsLoadId = token
        Task {
            let result = await dayStatsProvider(date)
            await MainActor.run {
                guard token == statsLoadId else { return }
                dayStats = result
            }
        }
    }
}
