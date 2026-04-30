import SwiftUI

struct PostponeMenuView: View {
    let todo: TodoEntity
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedDate: Date

    init(todo: TodoEntity, viewModel: MainViewModel) {
        self.todo = todo
        self.viewModel = viewModel
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: viewModel.selectedDate) ?? viewModel.selectedDate
        self._selectedDate = State(initialValue: nextDay)
    }

    var body: some View {
        ZStack {
            Color.panel.ignoresSafeArea()

            VStack(spacing: 0) {
                Text("언제로 미룰까요?")
                    .font(.galBold16())
                    .foregroundColor(.ink)
                    .padding(.top, 16)
                    .padding(.bottom, 14)

                // ── 빠른 선택 ─────────────────────────────────────────
                HStack(spacing: 8) {
                    quickChip(label: "내일",  days: 1)
                    quickChip(label: "모레",  days: 2)
                    quickChip(label: "+7일", days: 7)
                }
                .padding(.horizontal, 16)

                Rectangle()
                    .fill(Color.ink.opacity(0.12))
                    .frame(height: 1)
                    .padding(.horizontal, 16)
                    .padding(.top, 14)

                // ── 달력 ──────────────────────────────────────────────
                PixelCalendarPicker(
                    initialDate: selectedDate,
                    minimumDate: tomorrow,
                    externalDate: selectedDate,
                    onDateSelected: { selectedDate = $0 }
                )
                .padding(.top, 12)

                Spacer()

                // ── 확인 버튼 ─────────────────────────────────────────
                Button {
                    viewModel.postpone(id: todo.id, toDate: selectedDate)
                    dismiss()
                } label: {
                    HStack(spacing: 6) {
                        Text(dateLabel(selectedDate))
                            .font(.pressStart9())
                        Text("로 미루기")
                            .font(.galBold14())
                    }
                    .foregroundColor(.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(Color.peach)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                    .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Helpers

    private var tomorrow: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: viewModel.selectedDate) ?? viewModel.selectedDate
    }

    private func quickChip(label: String, days: Int) -> some View {
        let target = Calendar.current.date(byAdding: .day, value: days, to: viewModel.selectedDate) ?? viewModel.selectedDate
        let isSelected = Calendar.current.isDate(selectedDate, inSameDayAs: target)
        return Button { selectedDate = target } label: {
            Text(label)
                .font(.pressStart9())
                .foregroundColor(isSelected ? .cream : .ink)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(isSelected ? Color.ink : Color.cream)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        }
    }

    private func dateLabel(_ date: Date) -> String {
        let cal = Calendar.current
        let m = cal.component(.month, from: date)
        let d = cal.component(.day,   from: date)
        return String(format: "%02d/%02d", m, d)
    }
}
