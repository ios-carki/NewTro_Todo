//
//  MainTableViewCell.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/15.
//

import Foundation
import UIKit

import SnapKit
import RealmSwift

class MainTableViewCell: UITableViewCell {
    static let identifier = "tableCell"
    
    var id: ObjectId?
    let localRealm = try! Realm()
    
    let todoTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "일정을 입력하세요."
        view.translatesAutoresizingMaskIntoConstraints = false
        view.returnKeyType = .done
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        contentView.addSubview(todoTextField)
        todoTextField.delegate = self
    }
    
    private func setLayout() {
        todoTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(20)
            make.trailing.bottom.equalToSuperview().offset(-8)
        }
    }
    
//    override func prepareForReuse() {
//        self.todoTextField.text = nil
//    }
    
}

extension MainTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //방법1.
        //+버튼 누른 순간 테이블 형성
        //다음 테이블(셀)의 텍스트가 변하는게 아닌 1번째 테이블값이 변경 됨
        //let findTextFiled = localRealm.objects(Todo.self).first!
        //try! localRealm.write({
        //    findTextFiled.todo = textField.text
        //})

        //방법2.
        //방법1과 같은 결과
        //let findTextField = localRealm.objects(Todo.self)
        //try! localRealm.write {
        //    findTextField.first?.setValue(textField.text, forKey: "todo")
        //}
        
        //방법3.
        //데이터 업데이트는 셀에 맞춰서 되는데 모든 데이터값이 바뀜
        let findTextField = localRealm.objects(Todo.self)
        try! localRealm.write {
            findTextField.setValue(textField.text, forKey: "todo")
        }
        
        //방법4.ID로 바꾸기
        //앱 멈춤
        //try! localRealm.write {
        //    localRealm.create(Todo.self, value: ["objectID": id, "todo": textField.text], update: .modified)
        //}
        
        //방법5.방법3에서 iD도 주ㄱ
        //let findTextField = localRealm.objects(Todo.self)
        //try! localRealm.write {
        //    findTextField.setValue(<#T##value: Any?##Any?#>, forKey: <#T##String#>)//(textField.text, forKey: "todo")
        //}
        
        
        
        textField.resignFirstResponder()
        
        
        
        return true
    }
    
}
