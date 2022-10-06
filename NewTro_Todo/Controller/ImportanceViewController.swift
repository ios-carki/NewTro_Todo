//
//  ImportanceViewController.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/10/04.
//

import Foundation

import RealmSwift
import UIKit

final class ImportanceViewController: BaseViewController {
    
    let mainView = ImportanceView()
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current//Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current//TimeZone(abbreviation: "KST")
        formatter.dateFormat = "dateFormat".localized()
        
        return formatter
    }()
    var date: Date?
    
    let localRealm = try! Realm()
    var tasks: Results<Todo>! {
        didSet {
            mainView.importanceTableView.reloadData()
        }
    }
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableSetting()
        navigationSetting()
        fetchRealm()
        
        view.backgroundColor = .mainBackGroundColor
    }
    
    func fetchRealm() {
        //데이트포맷 바꾸기
        dateFormatter.dateFormat = "dateFormat".localized()
        
        //MARK: -- 날짜 변경에따른 테이블 뷰 갱신을위해 이부분 바꿔줌
        //변경 - > let convertDate = dateFormatter.string(from: nowDate)
        let convertDate = dateFormatter.string(from: date!)
        tasks = localRealm.objects(Todo.self).sorted(byKeyPath: "regDate", ascending: true)//.where {
            //$0.stringDate == convertDate
        //}//.sorted(byKeyPath: "", ascending: <#T##Bool#>)
    }
    
    func tableSetting() {
        mainView.importanceTableView.register(ImportanceViewCell.self, forCellReuseIdentifier: ImportanceViewCell.identifier) as? ImportanceViewCell
    }
    
    func navigationSetting() {
        title = "importanceView_NavigationBar_Title".localized()
        self.navigationController?.navigationBar.tintColor = .black
        
        mainView.importanceTableView.delegate = self
        mainView.importanceTableView.dataSource = self
    }
    
}

extension ImportanceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImportanceViewCell.identifier, for: indexPath) as! ImportanceViewCell
        
        cell.todoLabel.text = tasks[indexPath.row].todo
        
        if tasks[indexPath.row].isFinished {
            cell.completeView.backgroundColor = .blue
        } else {
            cell.completeView.backgroundColor = .red
        }
        
        return cell
    }
    
    
}
