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
    
    
    //메인에서 받아오는 선택된 날짜
//    var receivedNowDate = Date()
    var receivedNowDate = Date()
    
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        formatter.dateFormat = "yyyy년 MM월 dd일"
        
        return formatter
    }()
    
    @objc let plusButton: UIButton = {
        let view = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .light)
        let image = UIImage(systemName: "plus", withConfiguration: imageConfig)
        
        view.backgroundColor = .brown
        view.setImage(image, for: .normal)
            
        return view
    }()
    
    //타입지정
    var reloadCell: ( () -> () )?
    
    var tasks: Results<Todo>! {
        didSet {
            //여기 원래 리로드있었음
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
    
    //        print("셀 추가버튼 눌림")
    //
    //        let dateFormatter = DateFormatter()
    //        dateFormatter.locale = Locale(identifier: "ko_KR")
    //        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
    //        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
    
    @objc func plusButtonClicked() {
        let convertDate = dateFormatter.string(from: receivedNowDate)

        let task = Todo(todo: "", favorite: false, importance: 0, regDate: receivedNowDate, stringDate: convertDate, isFinished: false)
        
        try! localRealm.write({
            localRealm.add(task)
        })
        //MainVC -> 갱신
        reloadCell?()
    }
    
}
