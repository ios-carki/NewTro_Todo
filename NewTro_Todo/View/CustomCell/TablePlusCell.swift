//
//  TablePlusCell.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/15.
//

import Foundation
import UIKit

import SnapKit
import RealmSwift

class TablePlusCell: UITableViewCell {
    static let identifier = "tablePlusCell"
    let localRealm = try! Realm()
    let mainView = MainView()
    
    
    var nowDate = Date()
    //메인에서 받아오는 선택된 날짜
//    var receivedNowDate = Date()
//    var receivedNowDate: Date?
    var receivedNowDate = Date()
    
    @objc let plusButton: UIButton = {
        let view = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .light)
        let image = UIImage(systemName: "plus", withConfiguration: imageConfig)
        
        view.backgroundColor = .brown
        view.setImage(image, for: .normal)
            
        return view
    }()
    
    var reloadCell: ( () -> () )?
    var tasks: Results<Todo>! {
        didSet {
            //mainView.tableView.reloadSections(IndexSet(0...0), with: .automatic)
            print("데이터 변함!")
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        print("셀추가 누르기 전 받은 데이트", receivedNowDate)
        configure()
        setLayout()
        plusButton.addTarget(self, action: #selector(plusButtonClicked), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        contentView.addSubview(plusButton)
    }
    
    private func setLayout() {
        plusButton.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(safeAreaLayoutGuide)
            make.height.width.equalTo(40)
        }
    }
    
    func updateItem(item: Todo, todo: String?, importance: Int, regDate: Date) {
        do {
            try localRealm.write({
                item.todo = todo
                item.importance = importance
                item.regDate = regDate
            })
        } catch let error {
            print(error)
        }
    }
    
    @objc func plusButtonClicked() {
        print("셀 추가버튼 눌림")
//        MainViewController.addTableCell.append(TablePlusCell.identifier)
//        tasks.append()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        let convertDate = dateFormatter.string(from: receivedNowDate)
//
        
//        let formattedNowDate = dateFormatter
        let task = Todo(todo: "", favorite: false, importance: 0, regDate: receivedNowDate, stringDate: convertDate)
        
        try! localRealm.write({
            localRealm.add(task)
            print("변환날짜", convertDate)
            print("데이터 애드 될때 받은 데이트", receivedNowDate)
        })
        
        //mainView.tableView.reloadSections(IndexSet(0...0), with: .automatic)
        //print("추가버튼 누르고 배열속 배열 확인용: ", MainViewController.addTableCell)
        reloadCell?()
        //
        //print(MainViewController.addTableCell.count)
    }
    
}
