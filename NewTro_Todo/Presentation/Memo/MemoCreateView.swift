import SwiftUI
import UIKit

struct MemoCreateView: View {
    @ObservedObject var viewModel: MemoViewModel

    @State private var noteText: String = ""
    @State private var selectedColor: String = "yellow"
    @State private var requestFocus: Bool = false

    private let editorHeight: CGFloat = 180

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            popupCard
                .padding(.horizontal, 24)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                requestFocus = true
            }
        }
    }

    // MARK: - Popup Card
    // 색상 칩 선택은 titleBar 배경에만 반영. 본체는 panel(리스트 셀과 동일)로 고정.
    private var popupCard: some View {
        VStack(spacing: 0) {
            titleBar
            editorBody
            colorRow
            actionButtons
        }
        .background(Color.panel)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
    }

    // MARK: - Title Bar
    private var titleBar: some View {
        HStack {
            Text("메모 작성")
                .font(.galBold13())
                .foregroundColor(.ink)
            Spacer()
            Button { dismiss() } label: {
                Text("×")
                    .font(.pressStart10())
                    .foregroundColor(.ink)
                    .frame(width: 22, height: 22)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(MemoColorPalette.color(for: selectedColor))
        .overlay(
            Rectangle()
                .fill(Color.ink)
                .frame(height: 2),
            alignment: .bottom
        )
    }

    // MARK: - Editor
    private var editorBody: some View {
        ZStack(alignment: .topLeading) {
            UITextEditorWithToolbar(
                text: $noteText,
                requestFocus: $requestFocus,
                backgroundColor: UIColor(Color.panel)
            )
            .frame(height: editorHeight)

            if noteText.isEmpty {
                // 첫 줄은 title 폰트로 입력 시작 → placeholder도 동일 폰트로 정렬.
                Text("오늘의 생각을 기록해보세요...")
                    .font(.galBold16())
                    .foregroundColor(.shade.opacity(0.6))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .allowsHitTesting(false)
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
    }

    // MARK: - Color Row (Todo와 동일 패턴: 도트 아이콘 + "색상" + 가용폭 균등 스와치)
    private var colorRow: some View {
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
                        selectedColor = item.name
                    } label: {
                        let isSelected = selectedColor == item.name
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
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(minHeight: 36)
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 8) {
            Button { dismiss() } label: {
                Text("취소")
                    .font(.galBold11())
                    .foregroundColor(.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(Color.panel)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            }

            Button {
                viewModel.createMemo(note: noteText, colorName: selectedColor)
                dismiss()
            } label: {
                HStack(spacing: 4) {
                    Text("★")
                        .font(.pressStart10())
                    Text("저장")
                        .font(.galBold11())
                }
                .foregroundColor(.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(Color.ink.opacity(0.12))
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            }
            .disabled(noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }

    private func dismiss() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
        viewModel.isCreatePresented = false
    }
}

// MARK: - UITextView wrapper with keyboard inputAccessoryView
// 첫 줄 = 타이틀(galBold16), 줄바꿈 이후 = 본문(galBold13)로 자동 전환. iOS 기본 메모앱과 동일 거동.
private struct UITextEditorWithToolbar: UIViewRepresentable {
    @Binding var text: String
    @Binding var requestFocus: Bool
    let backgroundColor: UIColor

    static let titleFont: UIFont = UIFont(name: "Galmuri11-Bold", size: 16) ?? .systemFont(ofSize: 16, weight: .bold)
    static let bodyFont:  UIFont = UIFont(name: "Galmuri11-Bold", size: 13) ?? .systemFont(ofSize: 13)
    static let inkColor:  UIColor = UIColor(Color.ink)

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = backgroundColor
        textView.textColor = Self.inkColor
        // SwiftUI 오버레이 Placeholder(.padding 14)와 시작점을 일치시키기 위해
        // 기본 lineFragmentPadding(5pt)을 제거하고 inset을 14로 통일.
        textView.textContainerInset = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        textView.textContainer.lineFragmentPadding = 0
        textView.inputAccessoryView = makeAccessoryToolbar(coordinator: context.coordinator)
        textView.typingAttributes = [.font: Self.titleFont, .foregroundColor: Self.inkColor]
        Self.applyTitleBodyFonts(to: textView)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            let sel = uiView.selectedRange
            uiView.text = text
            Self.applyTitleBodyFonts(to: uiView)
            uiView.selectedRange = sel
        }
        uiView.backgroundColor = backgroundColor

        if requestFocus && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
            DispatchQueue.main.async { self.requestFocus = false }
        }
    }

    static func applyTitleBodyFonts(to textView: UITextView) {
        let raw = textView.text ?? ""
        let ns = raw as NSString
        let attr = NSMutableAttributedString(
            string: raw,
            attributes: [.font: bodyFont, .foregroundColor: inkColor]
        )
        let nlRange = ns.range(of: "\n")
        let firstLineLen = nlRange.location == NSNotFound ? ns.length : nlRange.location
        if firstLineLen > 0 {
            attr.addAttribute(.font, value: titleFont, range: NSRange(location: 0, length: firstLineLen))
        }
        textView.attributedText = attr
        updateTypingAttributes(for: textView)
    }

    static func updateTypingAttributes(for textView: UITextView) {
        let raw = textView.text ?? ""
        let ns = raw as NSString
        let cursorPos = min(textView.selectedRange.location, ns.length)
        let prefix = ns.substring(to: cursorPos)
        let onFirstLine = !prefix.contains("\n")
        textView.typingAttributes = [
            .font: onFirstLine ? titleFont : bodyFont,
            .foregroundColor: inkColor
        ]
    }

    private func makeAccessoryToolbar(coordinator: Coordinator) -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 1000, height: 40))

        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemGray5
        appearance.shadowColor = UIColor.separator
        toolbar.standardAppearance = appearance
        toolbar.scrollEdgeAppearance = appearance
        toolbar.compactAppearance = appearance
        toolbar.tintColor = UIColor.white
        toolbar.isTranslucent = false

        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let dismissButton = UIBarButtonItem(
            image: UIImage(systemName: "keyboard.chevron.compact.down"),
            style: .plain,
            target: coordinator,
            action: #selector(Coordinator.dismissKeyboard)
        )
        dismissButton.tintColor = UIColor(Color.ink)

        toolbar.items = [flex, dismissButton]
        toolbar.sizeToFit()
        return toolbar
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: UITextEditorWithToolbar
        init(_ parent: UITextEditorWithToolbar) { self.parent = parent }

        func textViewDidChange(_ textView: UITextView) {
            let sel = textView.selectedRange
            UITextEditorWithToolbar.applyTitleBodyFonts(to: textView)
            textView.selectedRange = sel
            parent.text = textView.text
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            UITextEditorWithToolbar.updateTypingAttributes(for: textView)
        }

        @objc func dismissKeyboard() {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil
            )
        }
    }
}
