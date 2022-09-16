//
//  MainCollectionViewCell.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/14.
//

import Foundation
import UIKit

import SnapKit

class MainCollectionViewCell: UICollectionViewCell {
    static let identifier = "colCell"
    static var tableTodoData: [String] = []
    
    let todoTableView: UITableView = {
        let view = UITableView()
//        view.backgroundColor = .mainBackGroundColor
        shadowEffect(view: view)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("받는데이터:",TablePlusCell.identifier)
        self.cellSetting()
        self.tableSetting()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cellSetting() {
        self.addSubview(todoTableView)
        
        todoTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func tableSetting() {
        todoTableView.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.identifier)//"todoTableCell")
        todoTableView.register(TablePlusCell.self, forCellReuseIdentifier: TablePlusCell.identifier)
        todoTableView.delegate = self
        todoTableView.dataSource = self
    }
    
}

extension MainCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    //섹션의 셀 개수니까
    //섹션 0 - 추가버튼 눌리면 1개씩 추가
    //섹션 1 - 고정(플러스버튼)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return MainCollectionViewCell.tableTodoData.count
        } else if section == 1 {
            return 1
        }
        return MainCollectionViewCell.tableTodoData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            //셀 생성 시점에 클로저로 전달
            let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath)
            return cell
        case 1:
            let plusCell = tableView.dequeueReusableCell(withIdentifier: TablePlusCell.identifier, for: indexPath)
            return plusCell
        default:
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "cel", for: indexPath)
            return cell1
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 50
        } else if indexPath.section == 1 {
            return 70
        }
        
        return 50
    }
    
    
}
