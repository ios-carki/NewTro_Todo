import SwiftUI

struct QuickNoteSheetView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var noteText: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                Capsule()
                    .fill(Color.ink.opacity(0.25))
                    .frame(width: 40, height: 4)
                    .padding(.top, 12)

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("MEMO")
                            .font(.pressStart9())
                            .foregroundColor(.pinkDk)
                        Text(viewModel.formattedDate)
                            .font(.galBold16())
                            .foregroundColor(.ink)
                    }
                    Spacer()
                    PixelArtView(grid: PixelArtAssets.starGrid, palette: PixelArtAssets.starPalette, scale: 2)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                TextEditor(text: $noteText)
                    .font(.galBold14())
                    .scrollContentBackground(.hidden)
                    .background(Color.panel)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                    .shadow(color: .ink, radius: 0, x: 3, y: 3)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .frame(minHeight: 180)

                HStack(spacing: 12) {
                    Button("취소") { dismiss() }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.panel)
                        .foregroundColor(.shade)
                        .font(.galBold14())
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))

                    Button("저장") {
                        viewModel.saveQuickNote(text: noteText)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.grass)
                    .foregroundColor(.white)
                    .font(.galBold14())
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                    .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
        }
        .presentationDetents([.fraction(0.55)])
        .presentationDragIndicator(.hidden)
        .onAppear {
            noteText = viewModel.quickNote?.note ?? ""
        }
    }
}
