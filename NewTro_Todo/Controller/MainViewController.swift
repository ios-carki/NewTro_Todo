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
//    let colCell = MainCollectionViewCell()
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
    }
    
    
    func fetchRealm() {
        tasks = localRealm.objects(Todo.self).sorted(byKeyPath: "regDate", ascending: true)
        //mainView.tableView.reloadSections(IndexSet(0...0), with: .automatic)
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
                
            }
            let importanceMID = UIAction(title: "중", image: nil) { action in
                let midGrade = self.localRealm.objects(Todo.self).where {
                    $0.objectID == cell.id!
                }.first
                try! self.localRealm.write {
                    midGrade?.setValue(1, forKey: "importance")
                }
            }
            let importanceLOW = UIAction(title: "하", image: nil) { action in
                let lowGrade = self.localRealm.objects(Todo.self).where {
                    $0.objectID == cell.id!
                }.first
                try! self.localRealm.write {
                    lowGrade?.setValue(0, forKey: "importance")
                }
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

