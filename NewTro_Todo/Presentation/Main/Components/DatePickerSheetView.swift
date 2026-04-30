import SwiftUI

struct DatePickerSheetView: View {
    let onDateSelected: (Date) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.panel.ignoresSafeArea()

            VStack(spacing: 0) {
                Text("날짜 이동")
                    .font(.galBold16())
                    .foregroundColor(.ink)
                    .padding(.top, 16)
                    .padding(.bottom, 14)

                PixelCalendarPicker { date in
                    onDateSelected(date)
                    dismiss()
                }
                .padding(.top, 4)

                Spacer()
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
