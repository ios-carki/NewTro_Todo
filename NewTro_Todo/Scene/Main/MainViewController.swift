//
//  MainViewController.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/09.
//

import Foundation
import UIKit

import RealmSwift
import SnapKit

final class MainViewController: BaseViewController {
    
    let mainView = MainView()
    let cellDetailCustomView = CustomMenuPopupView()
    let cellDetailCustomVC = CustomMenuPopupViewController()
    
    
    //MARK: -
    var calendar = Calendar.current
    
    //날짜계산을 위한 데이트변수
    var pickedNowDate = Date()
    //데이트포맷 다 바꾸기
    let dateFormatter = DateFormatter()
    
    //todo 상태
    var todoStatus: String?
    
    //MARK: -
    static var addTableCell: [String] = []
    
    let localRealm = try! Realm()
    var id: ObjectId?
    var tasks: Results<Todo>! {
        didSet {
            mainView.tableView.reloadData()
            print("데이터 변함!")
        }
    }
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //RealmFile URL
        print("Realm is located at:", localRealm.configuration.fileURL!)
        //MARK: -- Print
        navigationSetting()
        tableSetting()
        todoPlusTapGesture()
        quickNoteTapGesture()
        importanceViewTapGesture()
        fetchRealm()
        
        print("컨펌노티 상태: ", UserDefaults.standard.bool(forKey: "confirmNoti"))
        if UserDefaults.standard.bool(forKey: "confirmNoti") {
            print("컴펌노티 true로 통과")
        } else {
            requestAuthNoti()
            print("컴펌노티 false에서 true로 바뀌고 통과")
        }
        
        print("로컬 노티 상태: ", UserDefaults.standard.bool(forKey: "localNoti"))
        if UserDefaults.standard.bool(forKey: "localNoti") {
            self.sendNotiMessage(_seconds: 1.0, _title: "뉴트로 투두", _content: "오늘의 할 일을 작성해볼까요?")
        }
        
        userNotiCenter.removeAllPendingNotificationRequests()
//
        print(userNotiCenter.getPendingNotificationRequests(completionHandler: {requests in
            for request in requests {
                print("🩴🩴🩴🩴🩴🩴🩴🩴🩴🩴🩴🩴🩴🩴🩴🩴🩴🩴:", request )
            }
        }))
      
        mainView.leftButton.addTarget(self, action: #selector(yesterdayFunc), for: .touchUpInside)
        mainView.rightButton.addTarget(self, action: #selector(tomorrowFunc), for: .touchUpInside)
        
        //셀 삭제 노티
        //클로저로도 가능
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(self.didDismissDetailNotification(_:)),
          name: NSNotification.Name("DismissDetailView"),
          object: nil
        )
        
    }
    
    @objc func didDismissDetailNotification(_ notification: Notification) {
          DispatchQueue.main.async {
              self.mainView.tableView.reloadData()
          }
    }
    
    //날자 바꿀때마다 실행되어야 되니
    //처음 실행은 오늘날짜라 하더라도
    //날짜를 이동 - 해당 날짜
    //다른 뷰를 갔다와도 날짜유지
    func fetchRealm() {
        //데이트포맷 바꾸기
        dateFormatter.dateFormat = "dateFormat".localized()
        
        //MARK: -- 날짜 변경에따른 테이블 뷰 갱신을위해 이부분 바꿔줌
        //변경 - > let convertDate = dateFormatter.string(from: nowDate)
        let convertDate = dateFormatter.string(from: pickedNowDate)
        tasks = localRealm.objects(Todo.self).sorted(byKeyPath: "regDate", ascending: true).where {
            $0.stringDate == convertDate
        }//.sorted(byKeyPath: "", ascending: <#T##Bool#>)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.backgroundColor = .mainBackGroundColor
        super.viewWillAppear(animated)
        //테이블뷰의 키보드가 셀을 가릴때
        //keyboardObserver()
        print("로컬 노티 상태: ", UserDefaults.standard.bool(forKey: "localNoti"))
        
        fetchRealm()
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mainBackGroundColor]
    }
    
    func getPendingNotificationRequests(completionHandler: ([UNNotificationRequest]) -> Void) {}
    
    func navigationSetting() {
        let calendarButton = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: self, action: #selector(calendarButtonClicked))
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(menuButtonClicked))
        
        title = "navigationBar_Title".localized()
        navigationController?.navigationBar.backgroundColor = .calendarWeekdayColor
        navigationItem.leftBarButtonItem = calendarButton
        navigationItem.leftBarButtonItem?.tintColor = .gray
        
        navigationItem.rightBarButtonItem = menuButton
        navigationItem.rightBarButtonItem?.tintColor = .gray
    }
    
    func tableSetting() {
        mainView.tableView.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.identifier)
        mainView.tableView.register(TablePlusCell.self, forCellReuseIdentifier: TablePlusCell.identifier)
        

        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
        
    }
    
    //MARK: -- Noti
    //로컬 알림
    let userNotiCenter = UNUserNotificationCenter.current()
    
    func requestAuthNoti() {
        let notiAuthOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound]) // 노티 알림 설정 값
        self.userNotiCenter.requestAuthorization(options: notiAuthOptions) { (success, error) in
            // [success 부분에 권한을 허락하면 true / 권한을 허락하지 않으면 false 값이 들어갑니다]
            if let error = error {
                print("")
                print("===============================")
                print("[ViewController >> requestAuthNoti() :: 노티피케이션 권한 요청 에러]")
                print("[error :: \(error.localizedDescription)]")
                print("===============================")
                print("")
            }
            else {
                if success {
                    //권한 허락
                    //앱을 한번이라도 실행했으면 필요없고, 처음 실행한 사람들에 한해서 알림
                    //지금 문제는 처음에 알림 거부로 하면 영원히 거부되는 문제
//                    if UserDefaults.standard.bool(forKey: "oldUser") {
//
//                    } else {
//                        UserDefaults.standard.set(true, forKey: "localNoti")
//                    }
                    print("알림권한 허용함")
                    UserDefaults.standard.set(true, forKey: "localNoti")
                    print("로컬노티 권한값: ", UserDefaults.standard.bool(forKey: "localNoti"))
                } else {
//                    //권한 거부
//                    if UserDefaults.standard.bool(forKey: "oldUser") {
//
//                    } else {
//                        UserDefaults.standard.set(false, forKey: "localNoti")
//                    }
                    print("알림권한 거부함")
                    UserDefaults.standard.set(false, forKey: "localNoti")
                    print("로컬노티 권한값: ", UserDefaults.standard.bool(forKey: "localNoti"))
                }
            }
        }
        UserDefaults.standard.set(true, forKey: "confirmNoti")
    }
    
    func sendNotiMessage(_seconds: Double, _title: String, _content: String) {
        let calendar = Calendar.current
        let now = Date()
        
        //설정뷰에서 이부분 건들여주면 지정시간 알림
//        let date = calendar.date (
//            bySettingHour: 21,
//            minute: 30,
//            second: 0,
//            of: now
//        )!
        var date = DateComponents(timeZone: .current)
        date.hour = 19
        date.minute = 17
        
        // [알림 타이틀 및 내용 정의 실시]
        let notiContent = UNMutableNotificationContent()
        notiContent.title = _title // 타이틀
        notiContent.body = _content // 내용
        notiContent.badge = 1 // 뱃지 표시
        notiContent.sound = UNNotificationSound.default // 알림음 설정 [무음일 경우 진동]

        // [알림이 trigger 발생 되는 시간 설정]
        //let dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: _seconds, repeats: false)

        // [알림 값 설정 실시]
        let request = UNNotificationRequest(
            identifier: UUID().uuidString, // 식별자
            content: notiContent, // 알림 제목, 내용
            trigger: trigger // 발생 시간 정의
        )

        // [알림 추가 실시]
        self.userNotiCenter.add(request) { (error) in
            if let error = error {
                print("")
                print("===============================")
                print("[ViewController >> sendNotiMessage() :: 노티피케이션 알림 전송 에러]")
                print("[error :: \(error.localizedDescription)]")
                print("===============================")
                print("")
            }
        }
    }
    //MARK: -- Noti
    
    func todoPlusTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(todoPlusButtonClikced))
        mainView.todoPlusView.addGestureRecognizer(tapGesture)
    }
    
    @objc func todoPlusButtonClikced() {
        
        let convertDate = dateFormatter.string(from: pickedNowDate)
        let task = Todo(todo: "", favorite: false, importance: 0, regDate: Date(), stringDate: convertDate, isFinished: false)
        
        try! localRealm.write({
            localRealm.add(task)
        })
        mainView.tableView.reloadSections(IndexSet(0...0), with: .fade)
    }
    
    func quickNoteTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(quickNote))
        mainView.quickNoteView.addGestureRecognizer(tapGesture)
    }
    
    //퀵노트
    @objc func quickNote() {
        //옵셔널 id값을 선언하고 퀵노트가 만들어지면 id값 전달
        var noteID: ObjectId?
        let vc = CustomNotePopupViewController()
        let subVC = CalendarViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overCurrentContext
        
        subVC.dateCompletionHandler = {
            self.pickedNowDate = subVC.selectedDate
        }
    
        let strPickedNowDate = dateFormatter.string(from: pickedNowDate)
        vc.nowDate = pickedNowDate
        vc.receivedStrDate = strPickedNowDate
        
        //
        let isExisistedText = localRealm.objects(QuickNote.self).where {
            $0.stringToRegDate == strPickedNowDate
        }
        
        if isExisistedText.count == 0 {
            let task = QuickNote(note: "", regDate: pickedNowDate, stringToRegDate: strPickedNowDate, isWrited: false)

            try! localRealm.write({
                localRealm.add(task)
            })
            self.present(nav, animated: false)
        } else {
            self.present(nav, animated: false)
        }
        
    }
    
    func importanceViewTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(importanceViewClikced))
        mainView.importanceView.addGestureRecognizer(tapGesture)
    }
    
    @objc func importanceViewClikced() {
        let vc = ImportanceViewController()
        let nav = UINavigationController(rootViewController: vc)
        
        vc.tasks = self.tasks
        vc.date = pickedNowDate
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func calendarButtonClicked() {
        let vc = CalendarViewController()
        let nav = UINavigationController(rootViewController: vc)
        
        dateFormatter.dateFormat = "dateFormat".localized()
        //방법1
        vc.dateCompletionHandler = {
            self.pickedNowDate = vc.selectedDate
            let convertDate = self.dateFormatter.string(from: vc.selectedDate)
            print("전달된 데이트: ", convertDate)
            self.mainView.datePickBtn.setTitle(convertDate, for: .normal)
            self.fetchRealm()
            self.mainView.tableView.reloadData()
        }
        self.present(nav, animated: true)
    }
    
    @objc func menuButtonClicked() {
        let vc = SettingViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: -- cell dateCalculation
    @discardableResult func dayCalculation(formula: String) -> Date { // 월 별 일 수 계산
        dateFormatter.dateFormat = "dateFormat".localized()
        let result: Date?
        
        if formula == "plus" {
            print("현재날짜: ", pickedNowDate)
            result = calendar.date(byAdding: .day, value: 1,to: pickedNowDate)!
            print("+계산된 날짜", result)
            pickedNowDate = result!
            
            let formattedPickedDate = dateFormatter.string(from: pickedNowDate)
            mainView.datePickBtn.setTitle(formattedPickedDate, for: .normal)
            
            //**
            mainView.tableView.reloadSections(IndexSet(0...0), with: .left)
            
            return pickedNowDate
        } else {
            //값 전달을 pick가 아니라 계산된 값을 전달
            print("현재날짜: ", pickedNowDate)
            result = calendar.date(byAdding: .day, value: -1,to: pickedNowDate)!
            print("-계산된 날짜", result)
            pickedNowDate = result!
            
            let formattedPickedDate = dateFormatter.string(from: pickedNowDate)
            mainView.datePickBtn.setTitle(formattedPickedDate, for: .normal)
            
            //**
            mainView.tableView.reloadSections(IndexSet(0...0), with: .right)
            
            return pickedNowDate
        }
        
    }
    
    @objc func yesterdayFunc() {
        dayCalculation(formula: "minus")
        fetchRealm()
    }
    
    @objc func tomorrowFunc() {
        dayCalculation(formula: "plus")
        fetchRealm()
    }
}

//MARK: -- TableView
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    //MARK: -- Cell DetailButtonEvent(VC:CustomMenuPopupViewController)
    //check
    @objc func menuPopupButtonClicked(btnName: UIButton) {
        let nav = UINavigationController(rootViewController: cellDetailCustomVC)
        
        nav.modalPresentationStyle = .overCurrentContext
        cellDetailCustomVC.receivedTag = btnName.tag
        cellDetailCustomVC.tasks = self.tasks
        
        self.present(nav, animated: false)
    }
    
//    @objc func completeButtonClicked(btnName: UIButton) {
//
//        if tasks[btnName.tag].isFinished == false {
//            try! self.localRealm.write {
//                tasks[btnName.tag].isFinished = true
//            }
//        } else {
//            try! self.localRealm.write {
//                tasks[btnName.tag].isFinished = false
//            }
//        }
//        mainView.tableView.reloadSections(IndexSet(0...0), with: .none)
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tasks.count
    }
    
    @objc func makeToastMessageFunc(_ sender: UITextField) {
        guard let text = sender.text else { return }
        if text.count >= 50 {
            //view.makeToast("toastMessage".localized())
            view.makeToast("toastMessage".localized(), duration: 1.0, position: .top, title: nil, image: nil, style: .init(), completion: nil)
            //view.makeToastActivity(.top)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        //셀 생성 시점에 클로저로 전달
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
        

        cell.todoTextField.text = tasks[indexPath.row].todo!
        //셀 생성 시점에 id도 전달함
        cell.id = tasks[indexPath.row].objectID
        
        
        //투두 완료, 미루기
        if tasks[indexPath.row].isFinished {
            todoStatus = "todoStatus_notDone".localized()
        } else {
            todoStatus = "todoStatus_Done".localized()
        }
        
        let complete = UIAction(title: todoStatus ?? "todoStatus".localized()) { action in
            if self.tasks[cell.completeTodoBtn.tag].isFinished == false {
                try! self.localRealm.write {
                    self.tasks[cell.completeTodoBtn.tag].isFinished = true
                }
            } else {
                try! self.localRealm.write {
                    self.tasks[cell.completeTodoBtn.tag].isFinished = false
                }
            }
            self.mainView.tableView.reloadSections(IndexSet(0...0), with: .none)
        }
        cell.isCompleted = tasks[indexPath.row].isFinished
        
        //미루기 여기서 문제
        //cell.isDelayed =
        let postpone = UIAction(title: "다음날로 미루기") { action in
            
            if self.tasks[cell.completeTodoBtn.tag].isFinished {
                self.view.makeToast("already_completed_todo_toastMessage".localized(), duration: 1.0, position: .top, title: nil, image: nil, style: .init(), completion: nil)
            } else {
                try! self.localRealm.write {
                    self.tasks[cell.completeTodoBtn.tag].stringDate = self.dateFormatter.string(from: self.calendar.date(byAdding: .day, value: 1, to: self.pickedNowDate)!)
                }
            }
            //self.fetchRealm()
            self.mainView.tableView.reloadSections(IndexSet(0...0), with: .none)
        }
        
        //미루기 보관함 -> 보관함 X -> 간단하게 다음날로 업데이트 시켜주기
        cell.completeTodoBtn.menu = UIMenu(title: "투두 완료, 미루기", image: nil, identifier: nil, options: .displayInline, children: [complete, postpone])
        
        cell.todoTextField.addTarget(self, action: #selector(makeToastMessageFunc), for: .editingChanged)
        
        if tasks[indexPath.row].importance == 1 {
            cell.todoTextField.textColor = .blue
        } else if tasks[indexPath.row].importance == 2{
            cell.todoTextField.textColor = .yellow
        } else {
            cell.todoTextField.textColor = .white
        }
        
        if cell.isCompleted == true {
//            cell.todoBoundLine.isHidden = false
            cell.completeTodoLabel.isHidden = false
            cell.todoTextField.isHidden = true
            cell.importanceSelectBtn.isHidden = true
            cell.completeTodoLabel.attributedText = tasks[indexPath.row].todo?.strikeThrough()
            cell.completeTodoLabel.textColor = .lightGray
            
        } else {
//            cell.todoBoundLine.isHidden = true
            cell.completeTodoLabel.isHidden = true
            cell.todoTextField.isHidden = false
            cell.importanceSelectBtn.isHidden = false
        }
        cell.importanceSelectBtn.tag = indexPath.row //상세설정
        cell.completeTodoBtn.tag = indexPath.row //완료버튼
        cell.importanceSelectBtn.addTarget(self, action: #selector(menuPopupButtonClicked), for: .touchUpInside)
//        cell.completeTodoBtn.addTarget(self, action: #selector(completeButtonClicked), for: .touchUpInside)
        cell.backgroundColor = .cellBackGroundColor
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
    }
    
}

//extension MainViewController: UITextViewDelegate {
//
//    func textViewDidEndEditing(_ textView: UITextView) {
//        let stingNowDate = dateFormatter.string(from: pickedNowDate)
//
//        let todoText = localRealm.objects(Todo.self).where {
//            $0.stringDate == stingNowDate
//        }[textView.tag]
//        try! localRealm.write {
//            todoText.setValue(textView.text!, forKey: "todo")
//        }
//    }
//
////    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
////        if text == "\n" {
////            enterKeyCount += 1
////        }
////        print("개행 수: ", enterKeyCount)
////
////        if enterKeyCount > 5 {
////            view.makeToast("toastMessage".localized())
////            textView.endEditing(true)
////        }
////
////        return true
////    }
//
//    func textViewDidChange(_ textView: UITextView) {
//        let cell = MainTableViewCell()
//        mainView.tableView.beginUpdates()
//
////        let size = CGSize(width: cell.todoTextView.frame.width, height: .infinity)
////        let estimatedSize = textView.sizeThatFits(size)
////
////        textView.constraints.forEach { (constraint) in
////
////          /// 180 이하일때는 더 이상 줄어들지 않게하기
////            if estimatedSize.height >= 180 {
////
////            }
////            else {
////                if constraint.firstAttribute == .height {
////                    constraint.constant = estimatedSize.height
////                }
////            }
////        }
//        let fixedWidth = textView.frame.size.width
//        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//        var newFrame = textView.frame
//        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
//        textView.frame = newFrame
//
//        mainView.tableView.endUpdates()
//    }
//}

//extension UITextView {
//    func numberOfLine() -> Int {
//
//        let size = CGSize(width: frame.width, height: .infinity)
//        let estimatedSize = sizeThatFits(size)
//
//        return Int(estimatedSize.height / (self.font!.lineHeight))
//    }
//}


extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }
}
