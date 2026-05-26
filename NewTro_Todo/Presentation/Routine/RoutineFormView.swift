import SwiftUI

// 루틴 생성 / 수정 폼. RoutineView 가 .overlay 로 띄움.
// initial == nil → 신규 생성, initial != nil → 수정 (좌측 삭제 버튼 노출).
struct RoutineFormView: View {
    let initial: RoutineEntity?
    let onSave: (RoutineEntity) -> Void
    let onDelete: (() -> Void)?
    let onCancel: () -> Void

    // MARK: - Draft state
    @State private var title: String = ""
    @State private var startDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var endDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Calendar.current.startOfDay(for: Date())) ?? Date()
    @State private var repeatKind: RoutineRepeatKind = .daily
    @State private var weekdays: Set<Int> = []      // 1=일 ... 7=토
    @State private var monthDays: Set<Int> = []     // 1~31, 32=last
    @State private var yearMonth: Int = 0           // 1~12
    @State private var yearDay: Int = 0             // 1~31, 32=last
    @State private var isAllDay: Bool = true
    @State private var targetTimeStart: Date = defaultStartTime()
    @State private var targetTimeEnd: Date = defaultEndTime()
    @State private var colorName: String = "yellow"

    // 인라인 펼침 토글
    @State private var startDatePickerOpen: Bool = false
    @State private var endDatePickerOpen: Bool = false
    @State private var showDeleteConfirm: Bool = false

    var body: some View {
        ZStack {
            Color.panel.ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar
                    .padding(.horizontal, 12)
                    .padding(.top, 6)

                ScrollView {
                    VStack(spacing: 14) {
                        titleSection
                        colorSection
                        dateRangeSection
                        repeatKindSection
                        repeatSubForm
                        timeSection

                        if initial != nil, onDelete != nil {
                            deleteButton
                                .padding(.top, 8)
                        }

                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
        }
        .onAppear(perform: hydrateFromInitial)
        .alert("루틴을 삭제할까요?", isPresented: $showDeleteConfirm) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) { onDelete?() }
        } message: {
            Text("미래의 미완료 Todo 가 함께 제거됩니다.")
        }
    }

    // MARK: - Header bar
    private var headerBar: some View {
        HStack {
            PxXIcon { onCancel() }
            Spacer()
            Text(initial == nil ? "루틴 추가" : "루틴 수정")
                .font(.galBold16())
                .foregroundColor(.ink)
            Spacer()
            PxCheckIcon(disabled: !canSave) { commitSave() }
        }
    }

    private var canSave: Bool {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }
        guard Calendar.current.startOfDay(for: startDate) <= Calendar.current.startOfDay(for: endDate) else { return false }
        switch repeatKind {
        case .daily:
            return true
        case .weekly, .biweekly:
            return !weekdays.isEmpty
        case .monthly:
            return !monthDays.isEmpty
        case .yearly:
            return (1...12).contains(yearMonth) && yearDay > 0
        }
    }

    // MARK: - Title
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionLabel("할일")
            TextField("할 일을 입력하세요".localized(), text: $title)
                .font(.galCondensed16())
                .foregroundColor(.ink)
                .padding(10)
                .background(Color.tile)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
        }
    }

    // MARK: - Color
    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionLabel("색상")
            HStack(spacing: 8) {
                ForEach(MemoColorPalette.all, id: \.name) { item in
                    Button {
                        colorName = item.name
                    } label: {
                        let isActive = colorName == item.name
                        Rectangle()
                            .fill(item.color)
                            .frame(width: 32, height: 32)
                            .overlay(Rectangle().stroke(Color.ink, lineWidth: isActive ? 3 : 2))
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
        }
    }

    // MARK: - Date range
    private var dateRangeSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionLabel("기간")
            VStack(spacing: 8) {
                dateRow(label: "시작일", date: startDate, isOpen: startDatePickerOpen) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        startDatePickerOpen.toggle()
                        if startDatePickerOpen { endDatePickerOpen = false }
                    }
                }
                if startDatePickerOpen {
                    PixelDateWheel(
                        date: $startDate,
                        mode: .date,
                        minimumDate: Calendar.current.startOfDay(for: Date())
                    )
                    .onChange(of: startDate) { newValue in
                        if newValue > endDate {
                            endDate = newValue
                        }
                    }
                }

                dateRow(label: "종료일", date: endDate, isOpen: endDatePickerOpen) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        endDatePickerOpen.toggle()
                        if endDatePickerOpen { startDatePickerOpen = false }
                    }
                }
                if endDatePickerOpen {
                    PixelDateWheel(
                        date: $endDate,
                        mode: .date,
                        minimumDate: startDate
                    )
                }
            }
        }
    }

    private func dateRow(label: LocalizedStringKey, date: Date, isOpen: Bool, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack {
                Text(label)
                    .font(.galBold13())
                    .foregroundColor(.shade)
                Spacer()
                Text(dateLabel(date))
                    .font(.galBold14())
                    .foregroundColor(.ink)
            }
            .padding(.horizontal, 12)
            .frame(height: 38)
            .background(isOpen ? Color.sun : Color.cream)
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Repeat kind chips
    private var repeatKindSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionLabel("반복")
            HStack(spacing: 6) {
                ForEach(RoutineRepeatKind.allCases, id: \.self) { kind in
                    repeatKindChip(kind)
                }
                Spacer()
            }
        }
    }

    private func repeatKindChip(_ kind: RoutineRepeatKind) -> some View {
        let isActive = repeatKind == kind
        return Button {
            if repeatKind != kind {
                repeatKind = kind
                seedDefaultsForKind(kind)
            }
        } label: {
            Text(repeatKindLabel(kind))
                .font(.galBold11())
                .foregroundColor(isActive ? .cream : .ink)
                .padding(.horizontal, 8)
                .frame(height: 28)
                .background(isActive ? Color.ink : Color.panel)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    private func repeatKindLabel(_ kind: RoutineRepeatKind) -> LocalizedStringKey {
        switch kind {
        case .daily:    return "매일"
        case .weekly:   return "매주"
        case .biweekly: return "격주"
        case .monthly:  return "매월"
        case .yearly:   return "매년"
        }
    }

    // MARK: - Repeat sub-form
    @ViewBuilder
    private var repeatSubForm: some View {
        switch repeatKind {
        case .daily:
            EmptyView()
        case .weekly, .biweekly:
            weeklyPicker
        case .monthly:
            monthlyPicker
        case .yearly:
            yearlyPicker
        }
    }

    // weekly / biweekly 공용 — 요일 7개 칩 (다중 선택). 1=일 ... 7=토.
    private var weeklyPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionLabel("요일")
            HStack(spacing: 6) {
                ForEach(1...7, id: \.self) { wd in
                    weekdayChip(wd)
                }
            }
        }
    }

    private func weekdayChip(_ weekday: Int) -> some View {
        let isActive = weekdays.contains(weekday)
        return Button {
            if isActive {
                weekdays.remove(weekday)
            } else {
                weekdays.insert(weekday)
            }
        } label: {
            Text(RoutineSummary.weekdayShortName(weekday) ?? "")
                .font(.galBold13())
                .foregroundColor(isActive ? .cream : .ink)
                .frame(maxWidth: .infinity)
                .frame(height: 34)
                .background(isActive ? Color.ink : Color.panel)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    // monthly — 1~31 + 마지막날 (32). 7열 그리드.
    private var monthlyPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionLabel("일자")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(1...31, id: \.self) { d in
                    monthDayChip(rawValue: d, label: "\(d)")
                }
                monthDayChip(rawValue: 32, label: "마지막".localized())
            }
            if monthDays.contains(30) || monthDays.contains(31) {
                helperRow(text: "30일/31일이 없는 달에는 추가되지 않습니다")
            }
        }
    }

    private func monthDayChip(rawValue: Int, label: String) -> some View {
        let isActive = monthDays.contains(rawValue)
        return Button {
            if isActive { monthDays.remove(rawValue) } else { monthDays.insert(rawValue) }
        } label: {
            Text(label)
                .font(.galBold11())
                .foregroundColor(isActive ? .cream : .ink)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(isActive ? Color.ink : Color.panel)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }

    // yearly — 월(1~12) 그리드 + 일(1~31, 마지막날) 그리드.
    private var yearlyPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                sectionLabel("월 선택")
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 4), spacing: 4) {
                    ForEach(1...12, id: \.self) { m in
                        yearMonthChip(m)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 6) {
                sectionLabel("일자")
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                    ForEach(1...31, id: \.self) { d in
                        yearDayChip(rawValue: d, label: "\(d)")
                    }
                    yearDayChip(rawValue: 32, label: "마지막".localized())
                }
                if yearDay == 30 || yearDay == 31 {
                    helperRow(text: "30일/31일이 없는 달에는 추가되지 않습니다")
                }
            }
        }
    }

    private func yearMonthChip(_ m: Int) -> some View {
        let isActive = yearMonth == m
        return Button {
            yearMonth = m
        } label: {
            Text("%d월".localized(with: m))
                .font(.galBold13())
                .foregroundColor(isActive ? .cream : .ink)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(isActive ? Color.ink : Color.panel)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    private func yearDayChip(rawValue: Int, label: String) -> some View {
        let isActive = yearDay == rawValue
        return Button {
            yearDay = rawValue
        } label: {
            Text(label)
                .font(.galBold11())
                .foregroundColor(isActive ? .cream : .ink)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(isActive ? Color.ink : Color.panel)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Time section
    private var timeSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                sectionLabel("진행시각")
                Spacer()
                Text("종일".localized())
                    .font(.galBold13())
                    .foregroundColor(.shade)
                PxSwitch(isOn: isAllDay) {
                    withAnimation(.easeInOut(duration: 0.2)) { isAllDay.toggle() }
                }
            }
            if !isAllDay {
                VStack(spacing: 8) {
                    timeRow(label: "시작", date: $targetTimeStart)
                    timeRow(label: "끝", date: $targetTimeEnd)
                }
            }
        }
    }

    private func timeRow(label: LocalizedStringKey, date: Binding<Date>) -> some View {
        HStack {
            Text(label)
                .font(.galBold13())
                .foregroundColor(.shade)
                .frame(width: 36, alignment: .leading)
            DatePicker("", selection: date, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle(.compact)
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .background(Color.cream)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
    }

    // MARK: - Delete button
    private var deleteButton: some View {
        Button {
            showDeleteConfirm = true
        } label: {
            Text("루틴 삭제")
                .font(.galBold13())
                .foregroundColor(.cream)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.ink)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: LocalizedStringKey) -> some View {
        Text(text)
            .font(.galBold13())
            .foregroundColor(.shade)
    }

    private func helperRow(text: LocalizedStringKey) -> some View {
        HStack(spacing: 6) {
            Text("⚠")
                .font(.galBold11())
                .foregroundColor(.ink)
            Text(text)
                .font(.galBold11())
                .foregroundColor(.shade)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cream)
        .overlay(Rectangle().stroke(Color.ink.opacity(0.4), lineWidth: 1.5))
    }

    private func dateLabel(_ date: Date) -> String {
        let cal = Calendar.current
        return String(
            format: "%04d-%02d-%02d",
            cal.component(.year, from: date),
            cal.component(.month, from: date),
            cal.component(.day, from: date)
        )
    }

    private static func defaultStartTime() -> Date {
        Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    }

    private static func defaultEndTime() -> Date {
        Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) ?? Date()
    }

    // 신규 진입 시 + initial 변경 시 호출. State 초기화.
    private func hydrateFromInitial() {
        guard let r = initial else {
            // 신규 — weekly 기본값으로 오늘 요일 시드
            let todayWd = Calendar.current.component(.weekday, from: Date())
            weekdays = [todayWd]
            return
        }
        title = r.title
        startDate = Calendar.current.startOfDay(for: r.startDate)
        endDate = Calendar.current.startOfDay(for: r.endDate)
        repeatKind = r.repeatKind
        weekdays = Set(r.weekdays)
        monthDays = Set(r.monthDays.map(\.rawValue))
        yearMonth = r.yearMonth
        yearDay = r.yearDay?.rawValue ?? 0
        isAllDay = r.isAllDay
        if let s = r.targetTimeStart { targetTimeStart = s }
        if let e = r.targetTimeEnd { targetTimeEnd = e }
        colorName = r.colorName
    }

    // 반복 종류 전환 시 그 종류에 맞는 기본값 시드 (이미 채워져 있으면 유지).
    private func seedDefaultsForKind(_ kind: RoutineRepeatKind) {
        let cal = Calendar.current
        switch kind {
        case .daily:
            break
        case .weekly, .biweekly:
            if weekdays.isEmpty {
                weekdays = [cal.component(.weekday, from: Date())]
            }
        case .monthly:
            if monthDays.isEmpty {
                monthDays = [cal.component(.day, from: Date())]
            }
        case .yearly:
            if yearMonth == 0 { yearMonth = cal.component(.month, from: Date()) }
            if yearDay == 0 { yearDay = cal.component(.day, from: Date()) }
        }
    }

    private func commitSave() {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        let cal = Calendar.current
        let mDays: [RoutineDay] = monthDays.sorted().compactMap { RoutineDay(rawValue: $0) }
        let yDay: RoutineDay? = yearDay > 0 ? RoutineDay(rawValue: yearDay) : nil

        // 진행시각은 시각만 의미. materialize 시 targetDate 와 결합되므로 그대로 전달.
        let resolvedStart: Date? = isAllDay ? nil : targetTimeStart
        let resolvedEnd: Date? = isAllDay ? nil : targetTimeEnd

        let now = Date()
        let entity = RoutineEntity(
            id: initial?.id ?? "",
            title: trimmed,
            startDate: cal.startOfDay(for: startDate),
            endDate: cal.startOfDay(for: endDate),
            repeatKind: repeatKind,
            weekdays: Array(weekdays).sorted(),
            monthDays: mDays,
            yearMonth: (repeatKind == .yearly) ? yearMonth : 0,
            yearDay: (repeatKind == .yearly) ? yDay : nil,
            isAllDay: isAllDay,
            targetTimeStart: resolvedStart,
            targetTimeEnd: resolvedEnd,
            colorName: colorName,
            createdAt: initial?.createdAt ?? now,
            updatedAt: now
        )
        onSave(entity)
    }
}
