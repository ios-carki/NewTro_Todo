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
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        let convertDate = dateFormatter.string(from: nowDate)
//
//        let formattedNowDate = dateFormatter
        let task = Todo(todo: "", importance: 0, regDate: Date(), stringDate: convertDate)
        
        try! localRealm.write({
            localRealm.add(task)
        })
        
        //mainView.tableView.reloadSections(IndexSet(0...0), with: .automatic)
        //print("추가버튼 누르고 배열속 배열 확인용: ", MainViewController.addTableCell)
        reloadCell?()
        //
        //print(MainViewController.addTableCell.count)
    }
    
}
