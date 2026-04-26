import SwiftUI

struct MemoRangePickerView: View {
    @ObservedObject var viewModel: MemoViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("취소") { dismiss() }
                    .font(.pressStart9())
                    .foregroundColor(.shade)
                Spacer()
                Text("기간 설정")
                    .font(.pressStart9())
                    .foregroundColor(.ink)
                Spacer()
                Button("적용") {
                    viewModel.applyRangeFilter()
                    dismiss()
                }
                .font(.pressStart9())
                .foregroundColor(.grass)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.panel)
            .overlay(alignment: .bottom) { Color.ink.frame(height: 2) }

            ScrollView {
                VStack(spacing: 24) {
                    pickerRow(label: "시작일", date: $viewModel.rangeFrom)
                    pickerRow(label: "종료일", date: $viewModel.rangeTo)
                }
                .padding(16)
            }
        }
        .background(Color.sky.ignoresSafeArea())
    }

    private func pickerRow(label: String, date: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.pressStart9())
                .foregroundColor(.ink)
            DatePicker("", selection: date, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(.grass)
                .background(Color.panel)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        }
    }
}
