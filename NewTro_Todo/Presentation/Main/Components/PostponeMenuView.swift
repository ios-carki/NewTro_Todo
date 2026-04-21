import SwiftUI

struct PostponeMenuView: View {
    let todo: TodoEntity
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.panel.ignoresSafeArea()

            VStack(spacing: 0) {
                handleBar

                Text("언제로 미룰까요?")
                    .font(.galBold16())
                    .foregroundColor(.ink)
                    .padding(.top, 20)
                    .padding(.bottom, 16)

                VStack(spacing: 8) {
                    postponeOption(label: "내일 (+1일)", days: 1)
                    postponeOption(label: "모레 (+2일)", days: 2)
                    postponeOption(label: "이번 주말", days: daysUntilWeekend)
                    postponeOption(label: "다음 주 (+7일)", days: 7)
                }
                .padding(.horizontal, 20)

                Button {
                    dismiss()
                } label: {
                    Text("취소")
                        .font(.galBold14())
                        .foregroundColor(.shade)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.ink.opacity(0.08))
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
            }
        }
        .presentationDetents([.fraction(0.48)])
        .presentationDragIndicator(.hidden)
    }

    private var handleBar: some View {
        Capsule()
            .fill(Color.ink.opacity(0.25))
            .frame(width: 40, height: 4)
            .padding(.top, 12)
    }

    private func postponeOption(label: String, days: Int) -> some View {
        Button {
            let toDate = Calendar.current.date(byAdding: .day, value: days, to: viewModel.selectedDate) ?? viewModel.selectedDate
            viewModel.postpone(id: todo.id, toDate: toDate)
            dismiss()
        } label: {
            HStack {
                Text(label)
                    .font(.galBold14())
                    .foregroundColor(.ink)
                Spacer()
                Text("+\(days)d")
                    .font(.pressStart9())
                    .foregroundColor(.shade)
            }
            .padding(.horizontal, 14)
            .frame(height: 44)
            .background(Color.cream)
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            .shadow(color: .ink, radius: 0, x: 2, y: 2)
        }
    }

    private var daysUntilWeekend: Int {
        let weekday = Calendar.current.component(.weekday, from: viewModel.selectedDate)
        // weekday: 1=Sun, 7=Sat
        let daysToSat = (7 - weekday + 7) % 7
        return daysToSat == 0 ? 7 : daysToSat
    }
}
