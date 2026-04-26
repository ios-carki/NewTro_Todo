import SwiftUI

struct MemoFormView: View {
    @State private var noteText: String
    @State private var selectedColor: String
    @State private var isDeleted = false

    let memo: MemoEntity
    @ObservedObject var viewModel: MemoViewModel
    @Environment(\.dismiss) private var dismiss

    init(memo: MemoEntity, viewModel: MemoViewModel) {
        self.memo = memo
        self.viewModel = viewModel
        _noteText = State(initialValue: memo.note)
        _selectedColor = State(initialValue: memo.colorName)
    }

    private var isEditable: Bool {
        Calendar.current.isDateInToday(memo.targetDate)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            MemoColorPalette.color(for: selectedColor).ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                if !isEditable {
                    readOnlyBanner
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                }

                TextEditor(text: $noteText)
                    .font(.galBold16())
                    .foregroundColor(.ink)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .padding(.horizontal, 12)
                    .disabled(!isEditable)

                colorPicker
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
            }
        }
        .onDisappear {
            guard !isDeleted else { return }
            viewModel.saveMemo(id: memo.id, note: noteText, colorName: selectedColor)
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button("닫기") { dismiss() }
                .font(.pressStart9())
                .foregroundColor(.ink)

            Spacer()

            Text(dateLabel)
                .font(.pressStart7())
                .foregroundColor(.shade)

            Spacer()

            Button {
                isDeleted = true
                viewModel.deleteMemo(id: memo.id)
                dismiss()
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 15))
                    .foregroundColor(.pixelRed)
            }
        }
    }

    private var readOnlyBanner: some View {
        Text("오늘 날짜에만 작성 가능")
            .font(.pressStart7())
            .foregroundColor(.shade)
            .padding(6)
            .background(Color.panel.opacity(0.85))
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
    }

    // MARK: - Color Picker
    private var colorPicker: some View {
        HStack(spacing: 8) {
            ForEach(MemoColorPalette.all, id: \.name) { item in
                Button {
                    guard isEditable else { return }
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

    // MARK: - Helpers
    private var dateLabel: String {
        let cal = Calendar.current
        let y = cal.component(.year, from: memo.targetDate)
        let m = cal.component(.month, from: memo.targetDate)
        let d = cal.component(.day, from: memo.targetDate)
        return String(format: "%04d.%02d.%02d", y, m, d)
    }
}
