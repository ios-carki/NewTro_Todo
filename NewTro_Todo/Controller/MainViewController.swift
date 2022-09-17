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
//    let colCell = MainCollectionViewCell()
    static var addTableCell: [String] = []
    
    let localRealm = try! Realm()
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
        fetchRealm()
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mainBackGroundColor]
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //id전달
        let cellFile = MainTableViewCell()
        let findTextField = tasks[indexPath.row]
        
        cellFile.id = findTextField.objectID
        
        switch indexPath.section {
        case 0:
            //셀 생성 시점에 클로저로 전달
            let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
            
            cell.todoTextField.text = tasks[indexPath.row].todo!
            //fetchRealm()
            return cell
        case 1:
            let plusCell = tableView.dequeueReusableCell(withIdentifier: TablePlusCell.identifier, for: indexPath) as! TablePlusCell
            plusCell.reloadCell = {
                //tableView.reloadData()

                tableView.reloadSections(IndexSet(0...0), with: .automatic)
            }
//            fetchRealm()
//            let pageCell =
//            tableView.reloadData()
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
            return 50
        } else if indexPath.section == 1 {
            return 70
        }
        
        return 50
    }
    
    
}
