import SwiftUI

struct QuickNoteSheetView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var noteText: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(UIColor.mainBackGroundColor).ignoresSafeArea()

            VStack(spacing: 16) {
                Text(viewModel.formattedDate)
                    .font(.galBold20())
                    .foregroundColor(.white)
                    .padding(.top, 24)

                TextEditor(text: $noteText)
                    .font(.mainFont16())
                    .scrollContentBackground(.hidden)
                    .background(Color.textFieldC)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)

                HStack(spacing: 16) {
                    Button("취소") { dismiss() }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.textFieldC)
                        .foregroundColor(.white)
                        .cornerRadius(8)

                    Button("저장") {
                        viewModel.saveQuickNote(text: noteText)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color(UIColor.mainBackGroundColorWithOpacity))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            noteText = viewModel.quickNote?.note ?? ""
        }
    }
}
