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
    
    //옵셔널바인딩처리
    var id: ObjectId?
    
    let localRealm = try! Realm()
    
    let completeTodoBtn: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "ClearBtn"), for: .normal)
        view.imageView?.contentMode = .scaleToFill
        return view
    }()
    
    let todoTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "일정을 입력하세요."
        view.backgroundColor = .mainBackGroundColor
        view.font = .mainFont(size: 16)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.returnKeyType = .done
        return view
    }()
    
//    let storedView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .yellow
//
//        return view
//    }()
//
//    let importanceView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .white
//
//        return view
//    }()
    
    let importanceSelectBtn: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        view.tintColor = .black
        view.backgroundColor = .mainBackGroundColor
        //UIMenu터치 한번에
        //view.showsMenuAsPrimaryAction = true
        return view
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
        setLayout()
//        setImportance2Btn.addTarget(self, action: #selector(importance2ButtonClicked), for: .touchUpInside)
//        setImportance1Btn.addTarget(self, action: #selector(importance1ButtonClicked), for: .touchUpInside)
//        setImportance0Btn.addTarget(self, action: #selector(importance0ButtonClicked), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        contentView.addSubview(completeTodoBtn)
        contentView.addSubview(todoTextField)
        contentView.addSubview(importanceSelectBtn)
//        contentView.addSubview(importanceLabel)
//        contentView.addSubview(setImportanceView)
//        [importanceSelectedBtn, importanceSelectedLabel].map {
//            self.setImportanceView.addArrangedSubview($0)
//        }
        
        todoTextField.delegate = self
    }
    
    private func setLayout() {
        let standardMarkgin = 8
        
        completeTodoBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(standardMarkgin)
            make.trailing.equalTo(todoTextField.snp.leading).offset(-8)
            make.bottom.equalToSuperview().offset(-standardMarkgin)
            make.width.equalTo(40)
        }
        
        todoTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(standardMarkgin)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-standardMarkgin)
            make.width.equalTo(250)
        }
        
        importanceSelectBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(standardMarkgin)
            make.bottom.trailing.equalToSuperview().offset(-standardMarkgin)
        }
    }
}

extension MainTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let findTextField = localRealm.objects(Todo.self).where {
            $0.objectID == id!
        }.first
        try! localRealm.write {
            findTextField?.setValue(textField.text!, forKey: "todo")
        }
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let findTextField = localRealm.objects(Todo.self).where {
            $0.objectID == id!
        }.first
        try! localRealm.write {
            findTextField?.setValue(textField.text!, forKey: "todo")
        }
         
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let findTextField = localRealm.objects(Todo.self).where {
            $0.objectID == id!
        }.first
        try! localRealm.write {
            findTextField?.setValue(textField.text!, forKey: "todo")
        }
    }
    
}

