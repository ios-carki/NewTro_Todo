//
//  MainViewController.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/09.
//

import Foundation
import UIKit

import RealmSwift

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
        fetchRealm()
        
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
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        
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
        
        title = "메인"
        navigationController?.navigationBar.backgroundColor = .calendarWeekdayColor
        navigationItem.leftBarButtonItem = calendarButton
        navigationItem.leftBarButtonItem?.tintColor = .gray
        
        navigationItem.rightBarButtonItem = menuButton
        navigationItem.rightBarButtonItem?.tintColor = .gray
    }
    
    func tableSetting() {
        mainView.tableView.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.identifier) as? MainTableViewCell
        mainView.tableView.register(TablePlusCell.self, forCellReuseIdentifier: TablePlusCell.identifier) as? TablePlusCell
        
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
    
    @objc func calendarButtonClicked() {
        let vc = CalendarViewController()
        let nav = UINavigationController(rootViewController: vc)
        
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
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
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
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
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
            //셀 생성 시점에 클로저로 전달
            let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
            
            cell.todoTextField.text = tasks[indexPath.row].todo!
            //셀 생성 시점에 id도 전달함
            cell.id = tasks[indexPath.row].objectID
            cell.importanceSelectBtn.tag = indexPath.row //상세설정
            cell.completeTodoBtn.tag = indexPath.row //완료버튼
            cell.importanceSelectBtn.addTarget(self, action: #selector(menuPopupButtonClicked), for: .touchUpInside)
            cell.completeTodoBtn.addTarget(self, action: #selector(completeButtonClicked), for: .touchUpInside)
            cell.backgroundColor = .mainBackGroundColor
            cell.selectionStyle = .none
            return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 70
        } else if indexPath.section == 1 {
            return 60
        }
        return 50
    }
    
}
