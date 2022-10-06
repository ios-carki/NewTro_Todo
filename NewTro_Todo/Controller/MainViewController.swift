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

class MainViewController: BaseViewController {
    
    let mainView = MainView()
    let cellDetailCustomView = CustomMenuPopupView()
    let cellDetailCustomVC = CustomMenuPopupViewController()
    
    //MARK: -
    var calendar = Calendar.current
    
    //날짜계산을 위한 데이트변수
    var pickedNowDate = Date()
    //데이트포맷 다 바꾸기
    let dateFormatter = DateFormatter()
    
    
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
        //MARK: -- Print
        print("Realm is located at:", localRealm.configuration.fileURL!)
        //MARK: -- Print
        view.backgroundColor = .mainBackGroundColor
        navigationSetting()
        tableSetting()
        todoPlusTapGesture()
        quickNoteTapGesture()
        importanceViewTapGesture()
        fetchRealm()
        setLanguage()
        
        mainView.rightButton.addTarget(self, action: #selector(tomorrowFunc), for: .touchUpInside)
        mainView.leftButton.addTarget(self, action: #selector(yesterdayFunc), for: .touchUpInside)
        
        //셀 삭제 노티
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(self.didDismissDetailNotification(_:)),
          name: NSNotification.Name("DismissDetailView"),
          object: nil
        )
        
    }
    
    func setLanguage() {
        var language = UserDefaults.standard.array(forKey: "language")?.first as? String
        if language == nil {
            let str = String(NSLocale.preferredLanguages[0])    // 언어코드-지역코드 (ex. ko-KR, en-US)
            language = String(str.dropLast(3))                  // ko-KR => ko, en-US => en
        }
        
        // 해당 언어 파일 가져오기
        let path = Bundle.main.path(forResource: language, ofType: "lproj") ?? Bundle.main.path(forResource: "en", ofType: "lproj")
        let bundle = Bundle(path: path!)
        
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
        
        
        fetchRealm()
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mainBackGroundColor]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //키보드 끝나면 없앰
        //keyboardObserverRemove()
    }
    
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
        mainView.tableView.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.identifier) as? MainTableViewCell
        mainView.tableView.register(TablePlusCell.self, forCellReuseIdentifier: TablePlusCell.identifier) as? TablePlusCell
        
        
        mainView.tableView.rowHeight = UITableView.automaticDimension
        mainView.tableView.estimatedRowHeight = 500
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
        
    }
    
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
    func dayCalculation(formula: String) -> Date { // 월 별 일 수 계산
        dateFormatter.dateFormat = "dateFormat".localized()
        let result: Date?
        
        if formula == "plus" {
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
    
    @objc func completeButtonClicked(btnName: UIButton) {
        
        if tasks[btnName.tag].isFinished == false {
            try! self.localRealm.write {
                tasks[btnName.tag].isFinished = true
            }
        } else {
            try! self.localRealm.write {
                tasks[btnName.tag].isFinished = false
            }
        }
        mainView.tableView.reloadSections(IndexSet(0...0), with: .none)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tasks.count
    }
    
//    @objc func makeToastMessageFunc(_ sender: UITextField) {
//        guard let text = sender.text else { return }
//        if text.count >= 20 {
//            view.makeToast("toastMessage".localized())
//        }
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        //셀 생성 시점에 클로저로 전달
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
        
        cell.todoTextView.delegate = self
        cell.todoTextView.text = tasks[indexPath.row].todo!
        cell.todoTextView.tag = indexPath.row
        //셀 생성 시점에 id도 전달함
        cell.id = tasks[indexPath.row].objectID
        cell.isCompleted = tasks[indexPath.row].isFinished
        //cell.todoTextView.addTarget(self, action: #selector(makeToastMessageFunc), for: .editingChanged)
        
        if tasks[indexPath.row].importance == 1 {
            cell.todoTextView.textColor = .blue
        } else if tasks[indexPath.row].importance == 2{
            cell.todoTextView.textColor = .yellow
        } else {
            cell.todoTextView.textColor = .white
        }
        
        
        if cell.isCompleted == true {
//            cell.todoBoundLine.isHidden = false
            cell.completeTodoLabel.isHidden = false
            cell.todoTextView.isHidden = true
            cell.importanceSelectBtn.isHidden = true
            cell.completeTodoLabel.attributedText = tasks[indexPath.row].todo?.strikeThrough()
            cell.completeTodoLabel.textColor = .lightGray
            
        } else {
//            cell.todoBoundLine.isHidden = true
            cell.completeTodoLabel.isHidden = true
            cell.todoTextView.isHidden = false
            cell.importanceSelectBtn.isHidden = false
        }
        cell.importanceSelectBtn.tag = indexPath.row //상세설정
        cell.completeTodoBtn.tag = indexPath.row //완료버튼
        cell.importanceSelectBtn.addTarget(self, action: #selector(menuPopupButtonClicked), for: .touchUpInside)
        cell.completeTodoBtn.addTarget(self, action: #selector(completeButtonClicked), for: .touchUpInside)
        cell.backgroundColor = .cellBackGroundColor
        cell.selectionStyle = .none
        return cell
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//
//        return UITableView.automaticDimension
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//        return UITableView.automaticDimension
//    }
    
    
}

extension MainViewController: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let stingNowDate = dateFormatter.string(from: pickedNowDate)

        let todoText = localRealm.objects(Todo.self).where {
            $0.stringDate == stingNowDate
        }[textView.tag]
        try! localRealm.write {
            todoText.setValue(textView.text!, forKey: "todo")
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let cell = MainTableViewCell()
        mainView.tableView.beginUpdates()
        
        let size = CGSize(width: cell.todoTextView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)

        textView.constraints.forEach { (constraint) in

          /// 180 이하일때는 더 이상 줄어들지 않게하기
            if estimatedSize.height >= 180 {

            }
            else {
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                }
            }
        }
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame

        mainView.tableView.endUpdates()
    }
}


extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }
}
