import SwiftUI

struct DatePickerSheetView: View {
    let initialDate: Date
    let monthOverviewProvider: (Int, Int) async -> [Int: DayContent]
    let dayStatsProvider: (Date) async -> DayPreviewStats
    let monthCacheCheck: ((Int, Int) -> Bool)?
    let onDateConfirmed: (Date) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate: Date
    @State private var dayStats: DayPreviewStats? = nil
    @State private var statsLoadId: UUID = UUID()
    @State private var showWheelPicker: Bool = false
    @State private var wheelDate: Date = Date()
    /// PixelCalendarPicker 가 콜드 미스 materialize 중일 때 true.
    /// 시트의 하단 버튼 + interactive dismiss 도 함께 잠가, 로딩 중 사용자가
    /// 의도치 않게 다른 날짜로 이동/시트 닫기를 트리거하지 못하게 한다.
    @State private var isCalendarLoading: Bool = false

    init(
        initialDate: Date,
        monthOverviewProvider: @escaping (Int, Int) async -> [Int: DayContent],
        dayStatsProvider: @escaping (Date) async -> DayPreviewStats,
        monthCacheCheck: ((Int, Int) -> Bool)? = nil,
        onDateConfirmed: @escaping (Date) -> Void
    ) {
        self.initialDate = initialDate
        self.monthOverviewProvider = monthOverviewProvider
        self.dayStatsProvider = dayStatsProvider
        self.monthCacheCheck = monthCacheCheck
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
                    cacheCheck: monthCacheCheck,
                    onHeaderTap: {
                        wheelDate = selectedDate
                        showWheelPicker = true
                    },
                    onLoadingChange: { isCalendarLoading = $0 },
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
        // 콜드 미스 materialize 중엔 swipe-to-dismiss 도 잠금.
        // 사용자가 무의식 중 시트를 내려 진행 중인 청크 처리를 끊지 못하게 막는다.
        .interactiveDismissDisabled(isCalendarLoading)
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

                // selectedDate 의 달이 아직 materialize 안 됐다면 dayStats 도 부정확할 수 있음 → "--".
                // 단순 월 이동(이전에 본 날 그대로) 에서는 selectedDate 의 달이 이미 캐시돼 있어 정상 표시.
                if dayStats != nil || isStaleForSelectedDate {
                    statsGrid(stats: dayStats)
                } else {
                    Text("불러오는 중…")
                        .font(.galBold11())
                        .foregroundColor(.shade.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// 로딩 중이면서 selectedDate 가 속한 (year, month) 가 캐시 (materialize 완료) 되지 않은 상태.
    /// - 월 nav: selectedDate 의 달은 이전부터 선택돼 있던 달이라 보통 캐시됨 → false → 실제 숫자.
    /// - 휠 점프로 새 달의 날짜를 고른 직후: 캐시 미스라 true → "--".
    private var isStaleForSelectedDate: Bool {
        guard isCalendarLoading else { return false }
        let cal = Calendar.current
        let y = cal.component(.year, from: selectedDate)
        let m = cal.component(.month, from: selectedDate)
        return monthCacheCheck?(y, m) == false
    }

    private func statsGrid(stats: DayPreviewStats?) -> some View {
        HStack(spacing: 8) {
            statChip(label: "할 일 수", value: chipValue(stats?.totalTodos), accent: .ink)
            statChip(label: "완료", value: chipValue(stats?.completedTodos), accent: .grassDk)
            statChip(label: "미완료", value: chipValue(stats?.incompleteTodos), accent: .pinkDk)
            statChip(label: "메모", value: chipValue(stats?.memoCount), accent: .peachDk)
        }
    }

    private func chipValue(_ n: Int?) -> String {
        if isStaleForSelectedDate { return "--" }
        if let n { return "\(n)" }
        return "--"
    }

    private func statChip(label: LocalizedStringKey, value: String, accent: Color) -> some View {
        let isPlaceholder = value == "--"
        return VStack(spacing: 4) {
            Text(label)
                .font(.galBold10())
                .foregroundColor(.shade)
            Text(value)
                .font(.pressStart12())
                .foregroundColor(isPlaceholder ? .shade.opacity(0.5) : accent)
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
        // 비활성 조건: selectedDate 가 이미 오늘이거나, 캘린더가 콜드 미스 로딩 중인 경우.
        let dimmed = isSelectedToday || isCalendarLoading
        return Button {
            let today = Calendar.current.startOfDay(for: Date())
            selectedDate = today
            loadStats(for: today)
        } label: {
            Text("오늘")
                .font(.galBold13())
                .foregroundColor(.ink)
                .opacity(dimmed ? 0.3 : 1)
                .frame(width: 80, height: 48)
                .background(Color.cream)
                .overlay(Rectangle().stroke(dimmed ? Color.ink.opacity(0.25) : Color.ink, lineWidth: 2))
                .background(
                    Rectangle()
                        .fill(Color.ink)
                        .offset(x: 3, y: 3)
                        .opacity(dimmed ? 0 : 1)
                )
        }
        .disabled(dimmed)
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
                .opacity(isCalendarLoading ? 0.5 : 1)
        }
        .disabled(isCalendarLoading)
    }

    private var specificDateLabel: String {
        // locale-aware 날짜 + "%@로 이동" 포맷으로 다국어 대응 (년/월/일 하드코딩 제거).
        let f = DateFormatter()
        f.locale = .current
        f.setLocalizedDateFormatFromTemplate("yMMMd")
        return "%@로 이동".localized(with: f.string(from: selectedDate))
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
