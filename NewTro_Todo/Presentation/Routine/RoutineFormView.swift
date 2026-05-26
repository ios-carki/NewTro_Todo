import SwiftUI
import UIKit

// 루틴 생성 / 수정 폼.
// 두 그룹으로 분리:
//   [루틴 설정]   : 할일(텍스트), 기간(시작~종료), 반복(daily/weekly/...)
//   [Todo 설정]   : 색상, 중요도  (만들어질 각 Todo 에 그대로 복사됨)
// 시간/알림은 루틴 폼에 두지 않는다 (Todo 폼에서도 진행시각 기획이 폐기됨).
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
    @State private var importance: Importance = .none
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

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        groupHeader("루틴 설정")
                        sectionContainer { titleSection }
                        sectionContainer { dateRangeSection }
                        sectionContainer { repeatBlock }

                        groupDivider

                        groupHeader("Todo 설정")
                        sectionContainer { colorSection }
                        sectionContainer { importanceSection }

                        if initial != nil, onDelete != nil {
                            deleteButton
                                .padding(.top, 8)
                        }

                        Spacer(minLength: 60)
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

    // MARK: - Group header / divider
    // 두 그룹 (루틴 설정 / Todo 설정) 사이 시각 분리.
    private func groupHeader(_ text: LocalizedStringKey) -> some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(Color.ink)
                .frame(width: 12, height: 12)
            Text(text)
                .font(.galBold13())
                .foregroundColor(.ink)
            Spacer()
        }
        .padding(.horizontal, 2)
    }

    private var groupDivider: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color.ink).frame(height: 2)
            Rectangle().fill(Color.ink.opacity(0.25)).frame(height: 2)
        }
        .padding(.vertical, 6)
    }

    // 각 섹션 행을 감싸는 컨테이너 — Todo 폼의 sectionContainer 와 동일 톤.
    @ViewBuilder
    private func sectionContainer<V: View>(@ViewBuilder _ content: () -> V) -> some View {
        content()
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.ink.opacity(0.05))
    }

    // MARK: - Title (할일)
    // Todo 입력 필드와 동일한 AutoFocusTextField 사용 → placeholder 색/폰트가 동일.
    private var titleSection: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("할일")
                .font(.galBold14())
                .foregroundColor(.ink)
                .padding(.top, 6)
            VStack(spacing: 0) {
                AutoFocusTextField(
                    text: $title,
                    placeholder: NSLocalizedString("할 일을 입력하세요", comment: "Routine title placeholder"),
                    autoFocus: initial == nil,
                    font: UIFont.boldFont(size: 14),
                    textColor: UIColor(Color.ink),
                    placeholderColor: UIColor(Color.ink).withAlphaComponent(0.4),
                    accessibilityIdentifier: "routineTitleField",
                    onSubmit: { true },
                    charLimit: 100
                )
                .frame(minHeight: 34)
                Rectangle()
                    .fill(Color.ink.opacity(0.3))
                    .frame(height: 1.5)
            }
        }
    }

    // MARK: - Date range (기간)
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

    // MARK: - Repeat block (반복 + sub-form)
    private var repeatBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            repeatKindRow
            repeatSubForm
        }
    }

    private var repeatKindRow: some View {
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

    // MARK: - Color (Todo 폼과 동일 디자인)
    private var colorSection: some View {
        HStack(spacing: 8) {
            PixelArtView(
                grid: PixelArtAssets.dotPaletteGrid,
                palette: PixelArtAssets.dotPalettePalette,
                scale: 2
            )
            Text("색상")
                .font(.galBold14())
                .foregroundColor(.ink)

            HStack(spacing: 6) {
                ForEach(MemoColorPalette.all, id: \.name) { item in
                    Button {
                        colorName = item.name
                    } label: {
                        let isSelected = colorName == item.name
                        item.color
                            .frame(maxWidth: .infinity)
                            .frame(height: 30)
                            .overlay(
                                Rectangle().stroke(
                                    isSelected ? Color.ink : Color.ink.opacity(0.3),
                                    lineWidth: isSelected ? 2.5 : 1.5
                                )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(minHeight: 36)
    }

    // MARK: - Importance (Todo 폼과 동일 디자인)
    private var importanceSection: some View {
        HStack(spacing: 8) {
            PixelArtView(
                grid: PixelArtAssets.dotBarsGrid,
                palette: PixelArtAssets.dotBarsPalette,
                scale: 2
            )
            Text("중요도")
                .font(.galBold14())
                .foregroundColor(.ink)
            Spacer()
            HStack(spacing: 6) {
                importanceChip(.none,   label: "낮음")
                importanceChip(.medium, label: "보통")
                importanceChip(.high,   label: "높음")
            }
        }
        .frame(minHeight: 36)
    }

    private func importanceChip(_ imp: Importance, label: LocalizedStringKey) -> some View {
        let isSelected = importance == imp
        let chipBg: Color = switch imp {
        case .none:   .grassLt
        case .medium: .sunLt
        case .high:   .redLt
        }
        let selectedTextColor: Color = switch imp {
        case .none:   .grassDk
        case .medium: .sunDk
        case .high:   .redDk
        }
        return Button {
            importance = imp
        } label: {
            Text(label)
                .font(.galBold13())
                .foregroundColor(isSelected ? selectedTextColor : .ink)
                .padding(.horizontal, 10)
                .frame(height: 32)
                .background(isSelected ? chipBg : Color.cream)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        }
        .buttonStyle(.plain)
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

    // 신규 진입 시 + initial 변경 시 호출. State 초기화.
    private func hydrateFromInitial() {
        guard let r = initial else {
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
        importance = r.importance
        colorName = r.colorName
    }

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
            importance: importance,
            colorName: colorName,
            createdAt: initial?.createdAt ?? now,
            updatedAt: now
        )
        onSave(entity)
    }
}
