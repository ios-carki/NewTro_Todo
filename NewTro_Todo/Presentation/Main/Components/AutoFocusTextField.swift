import SwiftUI
import UIKit

// SwiftUI TextField + @FocusState로 onAppear 시점에 포커스를 주면
// 시트 애니메이션이 끝난 뒤에야 키보드가 올라와 "시트 → 잠시 뒤 키보드" 로 인지됨.
// UITextField는 didMoveToWindow (시트 호스트가 윈도우에 attach 되는 순간) 에
// becomeFirstResponder 호출이 가능해서 시트 등장 애니메이션과 키보드 등장이 동시에 발생함.
struct AutoFocusTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var autoFocus: Bool
    var font: UIFont
    var textColor: UIColor
    var placeholderColor: UIColor
    var accessibilityIdentifier: String? = nil
    // 키보드 Return(done) 키 누름 시 호출. 반환값으로 키보드 resign 여부를 결정.
    // true → resignFirstResponder (키보드 내림), false → 키보드 유지 (validation 실패 등).
    var onSubmit: (() -> Bool)? = nil

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> AutoFocusUITextField {
        let tf = AutoFocusUITextField()
        tf.shouldAutoFocus = autoFocus
        tf.delegate = context.coordinator
        tf.font = font
        tf.textColor = textColor
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: placeholderColor,
                .font: font,
            ]
        )
        tf.borderStyle = .none
        tf.backgroundColor = .clear
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.spellCheckingType = .no
        tf.returnKeyType = .done
        tf.accessibilityIdentifier = accessibilityIdentifier
        tf.text = text
        tf.addTarget(context.coordinator,
                     action: #selector(Coordinator.editingChanged(_:)),
                     for: .editingChanged)
        // 콘텐츠가 늘어나도 외부 레이아웃이 자기 폭을 지정. UIKit hugging이 끼어들지 않도록.
        tf.setContentHuggingPriority(.defaultLow, for: .horizontal)
        tf.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return tf
    }

    func updateUIView(_ uiView: AutoFocusUITextField, context: Context) {
        // 외부에서 text가 바뀐 경우(템플릿 자동 채움 등)에만 동기화 — 타이핑 중 cursor 재설정 회귀 방지.
        if uiView.text != text {
            uiView.text = text
        }
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: AutoFocusTextField
        init(_ parent: AutoFocusTextField) { self.parent = parent }

        @objc func editingChanged(_ sender: UITextField) {
            parent.text = sender.text ?? ""
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            // onSubmit 미지정 시 기본 동작: resign (return 키로 키보드 닫힘).
            let shouldResign = parent.onSubmit?() ?? true
            if shouldResign {
                textField.resignFirstResponder()
            }
            return shouldResign
        }
    }
}

// makeUIView 시점은 아직 window가 nil이라 becomeFirstResponder가 무시될 수 있음.
// 시트가 윈도우에 attach 되는 didMoveToWindow 직후가 가장 안전한 타이밍.
final class AutoFocusUITextField: UITextField {
    var shouldAutoFocus = false
    private var didAttemptFocus = false

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard shouldAutoFocus, !didAttemptFocus, window != nil else { return }
        didAttemptFocus = true
        becomeFirstResponder()
    }
}
