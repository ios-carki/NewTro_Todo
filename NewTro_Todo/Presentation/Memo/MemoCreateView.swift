import SwiftUI

struct MemoCreateView: View {
    @ObservedObject var viewModel: MemoViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var noteText: String = ""
    @State private var selectedColor: String = "yellow"

    var body: some View {
        ZStack(alignment: .bottom) {
            MemoColorPalette.color(for: selectedColor).ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                TextEditor(text: $noteText)
                    .font(.galBold16())
                    .foregroundColor(.ink)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .padding(.horizontal, 12)

                bottomBar
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var topBar: some View {
        HStack {
            Button("취소") { dismiss() }
                .font(.pressStart9())
                .foregroundColor(.shade)

            Spacer()

            Text("새 메모")
                .font(.galBold14())
                .foregroundColor(.ink)

            Spacer()

            Button {
                viewModel.createMemo(note: noteText, colorName: selectedColor)
                dismiss()
            } label: {
                Text("저장")
                    .font(.pressStart9())
                    .foregroundColor(.ink)
                    .padding(.horizontal, 12)
                    .frame(height: 30)
                    .background(Color.ink.opacity(0.1))
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
            }
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 8) {
            ForEach(MemoColorPalette.all, id: \.name) { item in
                Button {
                    selectedColor = item.name
                } label: {
                    item.color
                        .frame(width: 34, height: 34)
                        .overlay(
                            Rectangle().stroke(
                                selectedColor == item.name ? Color.ink : Color.ink.opacity(0.3),
                                lineWidth: selectedColor == item.name ? 3 : 1.5
                            )
                        )
                }
            }
            Spacer()
        }
    }
}
