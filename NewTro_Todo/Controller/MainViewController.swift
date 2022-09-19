//
//  MainViewController.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/09.
//

import Foundation
import UIKit

import RealmSwift
import Toast

class MainViewController: BaseViewController {
    
    let mainView = MainView()
    
    //MARK: -
    var components = DateComponents()
    var calendar = Calendar.current
    
    //날짜계산을 위한 데이트변수
    var pickedNowDate = Date()
    var sendDateInfo = TablePlusCell()
    //데이트포맷 다 바꾸기
    let dateFormatter = DateFormatter()
    //MARK: -
    static var addTableCell: [String] = []
    
    let localRealm = try! Realm()
    var id: ObjectId?
    var tasks: Results<Todo>! {
        didSet {
            mainView.tableView.reloadSections(IndexSet(0...0), with: .automatic)
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
        todoTapGesture()
        quickNoteTapGesture()
        fetchRealm()
        
        mainView.rightButton.addTarget(self, action: #selector(tomorrowFunc), for: .touchUpInside)
        mainView.leftButton.addTarget(self, action: #selector(yesterdayFunc), for: .touchUpInside)
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
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //테이블뷰의 키보드가 셀을 가릴때
        keyboardObserver()
        
        fetchRealm()
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mainBackGroundColor]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //키보드 끝나면 없앰
        keyboardObserverRemove()
    }
    
    //segue가 수행되려고 함을 뷰 컨트롤러에 알리는 작업
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tablePlusCell" {
            if let destination = segue.destination as?
                TablePlusCell {
                self.pickedNowDate = destination.receivedNowDate
            }
        }
    }
    
    func navigationSetting() {
        let calendarButton = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: self, action: #selector(calendarButtonClicked))
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal"), style: .plain, target: self, action: #selector(menuButtonClicked))
        
        title = "메인"
        navigationController?.navigationBar.backgroundColor = .mainBackGroundColor
        navigationItem.leftBarButtonItem = calendarButton
        navigationItem.leftBarButtonItem?.tintColor = .orange
        
        navigationItem.rightBarButtonItem = menuButton
        navigationItem.rightBarButtonItem?.tintColor = .orange
    }
    
    func tableSetting() {
        mainView.tableView.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.identifier) as? MainTableViewCell
        mainView.tableView.register(TablePlusCell.self, forCellReuseIdentifier: TablePlusCell.identifier) as? TablePlusCell
        
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
    }
    
    func todoTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(todoList))
        mainView.todoView.addGestureRecognizer(tapGesture)
    }
    
    @objc func todoList() {
        print("투두 클릭")
    }
    
    
    func quickNoteTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(quickNote))
        mainView.quickNoteView.addGestureRecognizer(tapGesture)
    }
    
    @objc func quickNote() {
        print("퀵노트 클릭")
    }
    
    @objc func calendarButtonClicked() {
        let vc = CalendarViewController()
        let nav = UINavigationController(rootViewController: vc)
        
        self.present(nav, animated: true)
    }
    
    @objc func menuButtonClicked() {
        let vc = SettingViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //MARK: -
    //메인에서 버튼이 보여지고 있는 날(일단은 Date()를 받아오기 때문에 현재날짜이지만
    //만약 캘린더 선택에서 날짜가 바귀면 현재 날짜 바껴줘야됨
    //그래서 일단 현재날짜를 받아와야 되는데
    //데이트 픽에서 날짜를 바꿔주면 그에 따라 같이 바궈줘야돼
    //지금 채택한 방법외에 더 좋은 방법이 있는지 ex)타임 인터벌...
    func dayCalculation(formula: String) -> Date { // 월 별 일 수 계산
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        let result: Date
        
        if formula == "plus" {
            result = calendar.date(byAdding: .day, value: 1,to: pickedNowDate)!
            print("+계산된 날짜", result)
            pickedNowDate = result
            
            //MARK: -- 고민한 부분
            //이부분 고민함
            //pickedNowDate를 버튼의 타이틀로할지, result를 버튼의 타이틀로 할지
            //밑에 else문도 마찬가지
            let formattedPickedDate = dateFormatter.string(from: pickedNowDate)
            mainView.datePickBtn.setTitle(formattedPickedDate, for: .normal)
            //MARK: -- 고민한 부분
            return result
        } else {
            result = calendar.date(byAdding: .day, value: -1,to: pickedNowDate)!
            print("-계산된 날짜", result)
            pickedNowDate = result
            
            let formattedPickedDate = dateFormatter.string(from: pickedNowDate)
            mainView.datePickBtn.setTitle(formattedPickedDate, for: .normal)
            return result
        }
        
    }
    //MARK: -
    @objc func yesterdayFunc() {
        print("어제버튼 눌림")
        dayCalculation(formula: "minus")
        sendDateInfo.receivedNowDate = pickedNowDate
        print("어제버튼 - 보낸 날짜", sendDateInfo.receivedNowDate)
        fetchRealm()
    }
    
    @objc func tomorrowFunc() {
        print("내일버튼 눌림")
        dayCalculation(formula: "plus")
        sendDateInfo.receivedNowDate = pickedNowDate
        print("내일버튼 - 보낸 날짜", pickedNowDate)
        fetchRealm()
    }
    
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    //섹션의 셀 개수니까
    //섹션 0 - 추가버튼 눌리면 1개씩 추가
    //섹션 1 - 고정(플러스버튼)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return tasks.count
            
        } else if section == 1 {
            return 1
        }
        return tasks.count
        
    }
    
    @objc func importanceBtnClicked() {
        self.view.makeToast("길게 누르면 중요도 선택이 가능합니다.")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        switch indexPath.section {
        case 0:
            //셀 생성 시점에 클로저로 전달
            let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
            
            //MARK: -- UIMenu 상중하
            let importanceHIGH = UIAction(title: "상", image: nil) { action in
                let highGrade = self.localRealm.objects(Todo.self).where {
                    $0.objectID == cell.id!
                }.first
                try! self.localRealm.write {
                    highGrade?.setValue(2, forKey: "importance")
                }
                cell.importanceView.backgroundColor = .mainBackGroundColor
                
            }
            let importanceMID = UIAction(title: "중", image: nil) { action in
                let midGrade = self.localRealm.objects(Todo.self).where {
                    $0.objectID == cell.id!
                }.first
                try! self.localRealm.write {
                    midGrade?.setValue(1, forKey: "importance")
                }
                cell.importanceView.backgroundColor = .systemCyan
            }
            let importanceLOW = UIAction(title: "하", image: nil) { action in
                let lowGrade = self.localRealm.objects(Todo.self).where {
                    $0.objectID == cell.id!
                }.first
                try! self.localRealm.write {
                    lowGrade?.setValue(0, forKey: "importance")
                }
                cell.importanceView.backgroundColor = .white
            }
            cell.importanceSelectBtn.menu = UIMenu(title: "중요도 선택", image: nil, identifier: nil, options: .displayInline, children: [importanceHIGH, importanceMID, importanceLOW])
            cell.importanceSelectBtn.addTarget(self, action: #selector(importanceBtnClicked), for: .touchUpInside)
            //MARK: -- UIMenu 상중하
            
            cell.todoTextField.text = tasks[indexPath.row].todo!
            //셀 생성 시점에 id도 전달함
            cell.id = tasks[indexPath.row].objectID
            //fetchRealm()
            
            
            
            return cell
        case 1:
            let plusCell = tableView.dequeueReusableCell(withIdentifier: TablePlusCell.identifier, for: indexPath) as! TablePlusCell
            plusCell.reloadCell = {
                tableView.reloadSections(IndexSet(0...0), with: .automatic)
            }
            
            tableView.reloadSections(IndexSet(0...0), with: .automatic)
            return plusCell
        default:
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "cel", for: indexPath)
            return cell1
        }
        
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
//        let thisCell = TablePlusCell() //해당 셀의 id
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 60
        } else if indexPath.section == 1 {
            return 70
        }
        
        return 50
    }
    
    
}

extension MainViewController {
    func keyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func keyboardObserverRemove() {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        
        @objc func keyboardShow(notification: NSNotification) {
            guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
//            self.view.frame.origin.y -=
//            self.view.frame.origin.y = 0 - keyboardSize.height
//            self.mainView.bottomView.frame.origin.y = 0 - keyboardSize.height
            self.mainView.bottomView.snp.remakeConstraints { make in
                make.top.equalTo(mainView.safeAreaLayoutGuide)
                make.leading.equalTo(mainView.safeAreaLayoutGuide).offset(20)
                make.trailing.equalTo(mainView.safeAreaLayoutGuide).offset(-20)
                make.bottom.equalTo(mainView.mainBackgroundImage.snp.top).offset(keyboardSize.height)
            }
        }
        
        @objc func keyboardHide(notification: NSNotification) {
//            self.constraint.constant += 100
//            self.view.frame.origin.y = 0
//            self.mainView.bottomView.frame.origin.y = 0
            self.mainView.bottomView.snp.remakeConstraints { make in
                make.top.equalTo(mainView.todoView.snp.bottom).offset(8)
                make.leading.equalTo(mainView.safeAreaLayoutGuide).offset(20)
                make.trailing.equalTo(mainView.safeAreaLayoutGuide).offset(-20)
                make.bottom.equalTo(mainView.mainBackgroundImage.snp.top)
            }
        }
}

