import SwiftUI

struct RoutineView: View {
    @ObservedObject var viewModel: RoutineViewModel
    @AppStorage("selectedCharacterId") private var selectedCharacterId: String = "pinko"

    private var selectedCharInfo: FriendCharInfo {
        CharacterData.all.first { $0.id == selectedCharacterId } ?? CharacterData.all[0]
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.top, 8)

            content
                .padding(.top, 8)
        }
        .overlay(alignment: .bottom) { FloatingTabBar() }
        .fullScreenCover(isPresented: Binding(
            get: { viewModel.isCreatePresented },
            set: { if !$0 { viewModel.dismissForm() } }
        )) {
            RoutineFormView(
                initial: nil,
                onSave: { entity in viewModel.saveCreated(entity) },
                onDelete: nil,
                onCancel: { viewModel.dismissForm() }
            )
        }
        .fullScreenCover(isPresented: Binding(
            get: { viewModel.isFormPresented && viewModel.editingRoutine != nil },
            set: { if !$0 { viewModel.dismissForm() } }
        )) {
            if let routine = viewModel.editingRoutine {
                RoutineFormView(
                    initial: routine,
                    onSave: { entity in viewModel.saveEdited(entity) },
                    onDelete: { viewModel.delete(id: routine.id) },
                    onCancel: { viewModel.dismissForm() }
                )
            }
        }
        .alert("오류", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("확인") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear { viewModel.loadRoutines() }
    }

    private var header: some View {
        HStack {
            Text("루틴")
                .font(.galBold22())
                .foregroundColor(.ink)
            Spacer()
            Button {
                viewModel.presentCreate()
            } label: {
                Text("+ 추가")
                    .font(.galBold11())
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

    @ViewBuilder
    private var content: some View {
        if viewModel.routines.isEmpty {
            ScrollView {
                emptyState.padding(.top, 60)
            }
            .clipAboveGround()
        } else {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.routines) { routine in
                        RoutineCardView(routine: routine)
                            .onTapGesture { viewModel.openRoutine(routine) }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, TabSceneLayout.contentBottomMargin)
            }
            .clipAboveGround()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            PixelPanel(bg: .cream, padding: 16) {
                VStack(spacing: 10) {
                    BobbingCharView(info: selectedCharInfo)
                    Text("루틴을 추가해보세요")
                        .font(.galBold14())
                        .foregroundColor(.ink)
                    Text("+ 추가 버튼으로 시작!")
                        .font(.galBold11())
                        .foregroundColor(.shade.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - RoutineCardView
// 좌측 색상 띠 + 제목 / 반복 요약 / 기간 표시.
private struct RoutineCardView: View {
    let routine: RoutineEntity
    private let stripWidth: CGFloat = 8

    var body: some View {
        HStack(spacing: 0) {
            MemoColorPalette.color(for: routine.colorName)
                .frame(width: stripWidth)
                .overlay(
                    Rectangle()
                        .fill(Color.ink)
                        .frame(width: 2),
                    alignment: .trailing
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(routine.title.isEmpty ? "제목 없음" : routine.title)
                    .font(.galBold16())
                    .foregroundColor(.ink)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(RoutineSummary.repeatLabel(routine))
                    .font(.galBold11())
                    .foregroundColor(.shade)

                Text(RoutineSummary.dateRangeLabel(routine))
                    .font(.pressStart8())
                    .foregroundColor(.ink.opacity(0.7))
                    .padding(.top, 2)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .background(Color.panel)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
    }
}

// MARK: - RoutineSummary (label helpers)
// RoutineFormView 와 RoutineCardView 에서 공유.
enum RoutineSummary {
    static func repeatLabel(_ r: RoutineEntity) -> String {
        switch r.repeatKind {
        case .daily:
            return "매일".localized()
        case .weekly:
            return weeklyLabel(prefix: "매주", weekdays: r.weekdays)
        case .biweekly:
            return weeklyLabel(prefix: "격주", weekdays: r.weekdays)
        case .monthly:
            let parts = r.monthDays.map(dayLabel(_:))
            if parts.isEmpty { return "매월".localized() }
            return "매월".localized() + " (" + parts.joined(separator: ", ") + ")"
        case .yearly:
            guard r.yearMonth >= 1, r.yearMonth <= 12, let yd = r.yearDay else {
                return "매년".localized()
            }
            let monthStr = "%d월".localized(with: r.yearMonth)
            return "매년".localized() + " \(monthStr) \(dayLabel(yd))"
        }
    }

    static func dateRangeLabel(_ r: RoutineEntity) -> String {
        "\(yyyyMMdd(r.startDate)) ~ \(yyyyMMdd(r.endDate))"
    }

    private static func weeklyLabel(prefix: String, weekdays: [Int]) -> String {
        let prefixL = prefix.localized()
        if weekdays.isEmpty { return prefixL }
        let names = weekdays.sorted().compactMap(weekdayShortName(_:))
        return prefixL + " (" + names.joined(separator: ", ") + ")"
    }

    static func weekdayShortName(_ weekday: Int) -> String? {
        // 1=일 ... 7=토 (Calendar.weekday)
        switch weekday {
        case 1: return "일".localized()
        case 2: return "월".localized()
        case 3: return "화".localized()
        case 4: return "수".localized()
        case 5: return "목".localized()
        case 6: return "금".localized()
        case 7: return "토".localized()
        default: return nil
        }
    }

    static func dayLabel(_ d: RoutineDay) -> String {
        switch d {
        case .day(let n): return "%d일".localized(with: n)
        case .last:       return "마지막날".localized()
        }
    }

    private static func yyyyMMdd(_ date: Date) -> String {
        let cal = Calendar.current
        return String(
            format: "%04d-%02d-%02d",
            cal.component(.year, from: date),
            cal.component(.month, from: date),
            cal.component(.day, from: date)
        )
    }
}
