//
//  CustomTextView.swift
//  NewTro_Todo
//
//  Created by OWEN on 11/18/24.
//
import UIKit
import SwiftUI

struct CustomTextView: UIViewRepresentable {
    
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.text = text
        //textView.text = placeHolderText // PlaceHolderText
        textView.textColor = .black
        textView.font = .mainFont(size: 16)
        textView.autocapitalizationType = .sentences
        //textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.backgroundColor = .cellBackGroundColor
        
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        textView.becomeFirstResponder()
        
        // MARK: Toolbar
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 44.0)))
        
        toolbar.backgroundColor = .black
        
        let keyboardDismissButton = UIBarButtonItem(image: UIImage(systemName: "keyboard.chevron.compact.down"), style: .plain, target: context.coordinator, action: #selector(context.coordinator.doneButtonTapped))
        let eraseDiaryText = UIBarButtonItem(title: "keyboard_toolbar_delete_button_text".localized(), style: .plain, target: context.coordinator, action: #selector(context.coordinator.eraseButtonTapped))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        keyboardDismissButton.tintColor = .black
        
        // 텍스트 속성 설정
        let eraseDiaryTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(NewtroColor.fail), // 텍스트 색상
            .font: UIFont.mainFont(size: 16)// 텍스트 폰트
        ]
        eraseDiaryText.setTitleTextAttributes(eraseDiaryTextAttributes, for: .normal)
        
        toolbar.items = [eraseDiaryText, flexibleSpace, keyboardDismissButton]
        
        textView.inputAccessoryView = toolbar
        
        
        textView.delegate = context.coordinator
        
        // Set coordinator's textView to textView instance
        context.coordinator.textView = textView
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        //        uiView.text = text
        //        uiView.backgroundColor = UIColor(Color.white)
        //        uiView.textColor = UIColor(Color.black)
        //        uiView.layer.cornerRadius = 6
        //        uiView.layer.borderColor = UIColor.black.cgColor
        //        uiView.layer.borderWidth = 1
    }
    
    func makeCoordinator() -> CustomTextViewCoordinator {
        CustomTextViewCoordinator(parent: self, $text)
    }
    
    class CustomTextViewCoordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextView
        var text: Binding<String>
        weak var textView: UITextView? // Keep a weak reference to UITextView
        
        init(parent: CustomTextView, _ text: Binding<String>) {
            self.parent = parent
            self.text = text
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.text.wrappedValue = textView.text
        }
        
        //In Focus
//        func textViewDidBeginEditing(_ textView: UITextView) {
//            if textView.text == placeHolderText {
//                textView.text = nil
//                textView.textColor = .black
//            }
//        }
//
//        func textViewDidEndEditing(_ textView: UITextView) {
//            if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                textView.text = placeHolderText
//                textView.textColor = .lightGray
//            }
//        }
        
        // MARK: Toolbar
        @objc func doneButtonTapped(_ textView: UITextView) {
            UIApplication.shared.dismissKeyboard()
        }
        
        @objc func eraseButtonTapped(_ textView: UITextView) {
            if let textView = self.textView {
                textView.text = ""
                self.text.wrappedValue = textView.text
            }
        }
    }
}
