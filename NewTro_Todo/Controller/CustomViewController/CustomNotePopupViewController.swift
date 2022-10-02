//
//  CustomNotePopupViewController.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/27.
//

import Foundation

import RealmSwift
import Toast
import UIKit

class CustomNotePopupViewController: BaseViewController {
    
    let mainView = CustomNotePopupView()
    let subView = MainViewController()
    
    var nowDate: Date?
    var receivedStrDate: String?
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current//Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current//TimeZone(abbreviation: "KST")
        formatter.dateFormat = "yyyy년 MM월 dd일"
        
        return formatter
    }()
    
    let localRealm = try! Realm()
    var id: ObjectId?
    var tasks: Results<QuickNote>! {
        didSet {
            print("데이터 변함!")
        }
    }
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showNoteText()
        
        let strNowDate = dateFormatter.string(from: nowDate!)
        
        let isExisistedText = localRealm.objects(QuickNote.self).where {
            $0.stringToRegDate == strNowDate
        }
        
        //날짜가 존재하면
        if isExisistedText != nil {
            mainView.noteTextView.text = isExisistedText[0].note
        } else {
            
//            addRealm()
        }
        
        mainView.noteCancelButton.addTarget(self, action: #selector(noteCancelButtonClicked), for: .touchUpInside)
        mainView.noteSaveButton.addTarget(self, action: #selector(noteSaveButtonclicked), for: .touchUpInside)
    }
    
//    func addRealm() {
//
//        let convertDate = dateFormatter.string(from: nowDate!)
//        let task = QuickNote(note: "", regDate: nowDate!, stringToRegDate: convertDate, isWrited: false)
//
//        try! localRealm.write({
//            localRealm.add(task)
//        })
//    }
    
    func showNoteText() {
        let findDate = localRealm.objects(QuickNote.self).where {
            $0.regDate == nowDate!
        }.first?.note
        
        mainView.noteTextView.text = findDate
    }
    
    @objc func noteCancelButtonClicked() {
        self.dismiss(animated: false)
    }
    
    @objc func noteSaveButtonclicked() {
        print("저장버튼 눌림")
        
        let userNoteText = mainView.noteTextView.text
        let strNowDate = dateFormatter.string(from: nowDate!)
        print("스트링 나우데이트: ", strNowDate)
        
        let findID = localRealm.objects(QuickNote.self).where {
            $0.stringToRegDate == strNowDate
        }.first
        try! self.localRealm.write {
            findID?.setValue(userNoteText, forKey: "note")
        }
        
        try! self.localRealm.write {
            findID?.setValue(true, forKey: "isWrited")
        }
        
        view.makeToast("NoteSaveButtonClicked_ToastMessage".localized())
        
        
    }
    
}
