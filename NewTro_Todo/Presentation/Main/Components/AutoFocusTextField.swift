import SwiftUI
import UIKit

// SwiftUI TextField + @FocusState로 onAppear 시점에 포커스를 주면
// 시트 애니메이션이 끝난 뒤에야 키보드가 올라와 "시트 → 잠시 뒤 키보드" 로 인지됨.
// UITextView 는 didMoveToWindow (시트 호스트가 윈도우에 attach 되는 순간) 에
// becomeFirstResponder 호출이 가능해서 시트 등장과 키보드 등장이 동시에 발생함.
//
// UITextField → UITextView 로 교체된 이유:
//  - 작성한 긴 텍스트를 편집 화면에서 잘려 보이는 (...) 문제 해결.
//  - 자동 wrap 으로 멀티라인 표현. 화면 형태에 따른 분기는 onMultilineDetected 콜백 유무로:
//      compact:  onMultilineDetected 콜백 → 1줄 넘는 순간 expanded 자동 전환 트리거
//      expanded: 콜백 없음 → onHeightChange 콜백으로 SwiftUI 측 frame height 동기. 캡은 호출부에서.
//  - 같은 view 인스턴스를 morph 에 재사용하므로 transition 시 keyboard 유지.
//  - return(\n) 키는 줄바꿈이 아니라 onSubmit 트리거 — \n 은 차단해 의도와 무관한 줄바꿈 입력을 막음.
struct AutoFocusTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var autoFocus: Bool
    var font: UIFont
    var textColor: UIColor
    var placeholderColor: UIColor
    var accessibilityIdentifier: String? = nil
    // 키보드 Return(done) 키 누름 시 호출. true → resignFirstResponder, false → 키보드 유지.
    var onSubmit: (() -> Bool)? = nil
    // 한 줄을 넘는 wrap 이 발생한 순간 호출. compact → expanded 자동 전환 트리거.
    var onMultilineDetected: (() -> Void)? = nil
    // 최대 글자 수. nil = 제한 없음. 입력 단계에서 차단.
    var charLimit: Int? = nil
    // UITextView 가 현재 콘텐츠 기준 측정한 실제 height 를 SwiftUI 에 보고.
    // SwiftUI 가 이 값으로 .frame(height:) 적용 → 콘텐츠에 따른 정확한 height 동기.
    //   UIViewRepresentable 의 intrinsicContentSize override 가 SwiftUI layout 에서
    //   누락되는 케이스가 있어, 명시 binding 으로 강제.
    var onHeightChange: ((CGFloat) -> Void)? = nil

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> AutoFocusUITextView {
        let tv = AutoFocusUITextView()
        tv.shouldAutoFocus = autoFocus
        tv.delegate = context.coordinator
        tv.onMeasuredHeight = { [weak coord = context.coordinator] h in
            coord?.parent.onHeightChange?(h)
        }
        tv.font = font
        tv.textColor = textColor
        tv.backgroundColor = .clear
        // 좌우 패딩 0. 상 6, 하 14 — 마지막 줄(특히 5줄째) 의 descender 가 frame bottom 까지 닿지 않도록
        //   bottom 을 더 키움. 밑줄(VStack 의 underline Rectangle) 은 frame 바로 아래 그대로 → 디자인 유지,
        //   텍스트와의 시각 간섭만 제거.
        tv.textContainerInset = UIEdgeInsets(top: 6, left: 0, bottom: 14, right: 0)
        tv.textContainer.lineFragmentPadding = 0
        tv.autocorrectionType = .no
        tv.autocapitalizationType = .none
        tv.spellCheckingType = .no
        tv.returnKeyType = .done
        tv.accessibilityIdentifier = accessibilityIdentifier
        // 스크롤 OFF — 콘텐츠 높이만큼 SwiftUI .frame 이 자유롭게 늘어남. 캡 없이 진행하기 때문에
        //   layoutManager 가 "남은 공간 없음" 으로 wrap 을 끊는 boundary 케이스가 발생하지 않음
        //   (캡 둔 채로 scroll OFF 하면 캡 도달 직전 wrap 끊김 회귀). 글자수 charLimit 이 사실상 가드.
        tv.isScrollEnabled = false
        tv.text = text

        // Placeholder UILabel 오버레이 — UITextView 는 placeholder 미지원.
        let label = UILabel()
        label.text = placeholder
        label.font = font
        label.textColor = placeholderColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = !text.isEmpty
        tv.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: tv.topAnchor, constant: 6),
            label.leadingAnchor.constraint(equalTo: tv.leadingAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: tv.trailingAnchor),
        ])
        tv.placeholderLabel = label

        tv.setContentHuggingPriority(.defaultLow, for: .horizontal)
        tv.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        // textContainer 가 textView width 를 따라가도록 명시 — wrap 의 전제조건. default 가 true 이지만
        // 우선순위 조정 등 다른 요인과 함께 흐트러지는 경우 방어.
        tv.textContainer.widthTracksTextView = true
        tv.textContainer.lineBreakMode = .byWordWrapping
        return tv
    }

    func updateUIView(_ uiView: AutoFocusUITextView, context: Context) {
        // 외부에서 text가 바뀐 경우(템플릿 자동 채움 등)에만 동기화 — 타이핑 중 cursor 재설정 회귀 방지.
        if uiView.text != text {
            uiView.text = text
        }
        uiView.placeholderLabel?.isHidden = !uiView.text.isEmpty
        // 외부에서 text 가 갱신된 경우(템플릿 적용 등)에도 height 재보고.
        uiView.reportMeasuredHeight()
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: AutoFocusTextField
        // 1회만 호출되도록 latch — wrap 발생 이후 매 입력마다 콜백 재호출 방지.
        var didNotifyMultiline = false
        init(_ parent: AutoFocusTextField) { self.parent = parent }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            let tv = textView as? AutoFocusUITextView
            tv?.placeholderLabel?.isHidden = !textView.text.isEmpty

            // 텍스트 변화 직후 콘텐츠 height 재측정 → SwiftUI 로 보고. 줄 늘어남/줄어듦 모두 반영.
            tv?.reportMeasuredHeight()

            // wrap 감지 — 1줄을 넘어가는 순간 onMultilineDetected 호출 (compact → expanded).
            if let cb = parent.onMultilineDetected, !didNotifyMultiline {
                if AutoFocusTextField.numberOfLines(in: textView) > 1 {
                    didNotifyMultiline = true
                    cb()
                }
            }
        }

        func textView(_ textView: UITextView,
                      shouldChangeTextIn range: NSRange,
                      replacementText text: String) -> Bool {
            // return 키 — 명시적 \n 입력은 차단. 멀티라인은 자동 wrap 으로만 표현.
            if text == "\n" {
                let shouldResign = parent.onSubmit?() ?? true
                if shouldResign {
                    textView.resignFirstResponder()
                }
                return false
            }
            // 글자수 제한 — 붙여넣기로 한 번에 넘는 경우도 차단. NSString length 기준(UTF-16)
            // 이라 이모지가 2 단위로 계산되지만 사용자 경험상 충분히 안전한 상한.
            if let limit = parent.charLimit {
                let current = (textView.text ?? "") as NSString
                let newLength = current.length - range.length + (text as NSString).length
                if newLength > limit { return false }
            }
            return true
        }
    }

    // layoutManager 로 실제 wrap 결과 줄 수 측정. contentSize 보다 즉시성 좋음.
    static func numberOfLines(in textView: UITextView) -> Int {
        let layoutManager = textView.layoutManager
        var lineCount = 0
        var index = 0
        let glyphCount = layoutManager.numberOfGlyphs
        var lineRange = NSRange()
        while index < glyphCount {
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange)
            lineCount += 1
        }
        return max(lineCount, 1)
    }
}

// makeUIView 시점은 아직 window가 nil이라 becomeFirstResponder가 무시될 수 있음.
// 시트가 윈도우에 attach 되는 didMoveToWindow 직후가 가장 안전한 타이밍.
final class AutoFocusUITextView: UITextView {
    var shouldAutoFocus = false
    var placeholderLabel: UILabel?
    // 콘텐츠 height 가 갱신될 때마다 SwiftUI 로 보고. Coordinator 가 parent.onHeightChange 호출 매개.
    var onMeasuredHeight: ((CGFloat) -> Void)?

    private var didAttemptFocus = false
    private var lastReportedHeight: CGFloat = -1
    private var lastLayoutWidth: CGFloat = 0

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard shouldAutoFocus, !didAttemptFocus, window != nil else { return }
        didAttemptFocus = true
        // didMoveToWindow 시점엔 RTI 세션이 아직 미발급 상태라 즉시 호출 시
        // sessionID 재시도 로그 + 살짝 딜레이가 발생. 다음 런루프 tick으로 미룸.
        DispatchQueue.main.async { [weak self] in
            self?.becomeFirstResponder()
        }
    }

    // width 가 처음 정해지거나 변경될 때 height 다시 보고. bounds.width 같으면 보고 스킵.
    override func layoutSubviews() {
        super.layoutSubviews()
        if abs(bounds.width - lastLayoutWidth) > 0.5 {
            lastLayoutWidth = bounds.width
            reportMeasuredHeight()
        }
    }

    // 현재 콘텐츠 기준 sizeThatFits 로 측정한 height 를 SwiftUI 로 보고. 같은 값이면 스킵 — 무한 루프 방지.
    func reportMeasuredHeight() {
        guard bounds.width > 0 else { return }
        let h = ceil(sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude)).height)
        guard abs(h - lastReportedHeight) > 0.5 else { return }
        lastReportedHeight = h
        onMeasuredHeight?(h)
    }

}
