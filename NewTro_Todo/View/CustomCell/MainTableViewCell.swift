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
    let mainView = MainViewController()
    
    //옵셔널바인딩처리
    var id: ObjectId?
    var isCompleted: Bool?
    
    let localRealm = try! Realm()
    
    let completeTodoBtn: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "ClearBtn"), for: .normal)
        view.imageView?.contentMode = .scaleToFill
        return view
    }()
    
    let todoTextField: UITextField = {
        let view = UITextField()
        view.isHidden = false
        view.placeholder = "일정을 입력하세요."
        view.backgroundColor = .cellBackGroundColor
        view.font = .mainFont(size: 16)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.returnKeyType = .done
        return view
    }()
    
    let importanceSelectBtn: UIButton = {
        let view = UIButton()
        view.isHidden = false
        view.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        view.tintColor = .black
        view.backgroundColor = .cellBackGroundColor
        
        return view
    }()
    
    let completeTodoLabel: UILabel = {
        let view = UILabel()
        view.isHidden = true
        view.textColor = .black
        view.font = .mainFont(size: 16)
        return view
    }()
    
//    let todoBoundLine: UIView = {
//        let view = UIView()
//        view.isHidden = true
//        view.layer.borderColor = UIColor.black.cgColor
//        view.layer.borderWidth = 1
//        return view
//    }()
    
//    let completeOverwrapImage: UIImageView = {
//        let view = UIImageView()
//        view.isHidden = true
//        view.image = UIImage(named: "TodoClear")
//        view.contentMode = .scaleAspectFit
//        return view
//    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        
//        contentView.addSubview(completeOverwrapImage)
        contentView.addSubview(completeTodoBtn)
        contentView.addSubview(todoTextField)
        contentView.addSubview(importanceSelectBtn)
        contentView.addSubview(completeTodoLabel)
//        contentView.addSubview(todoBoundLine)
        
        todoTextField.delegate = self
    }
    
    private func setLayout() {
        let standardMarkgin = 8
        
        completeTodoBtn.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(standardMarkgin)
            make.bottom.equalToSuperview().offset(-standardMarkgin)
            make.width.equalTo(40)
        }
        
        todoTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(standardMarkgin)
            make.bottom.equalToSuperview().offset(-standardMarkgin)
            make.leading.equalTo(completeTodoBtn.snp.trailing).offset(standardMarkgin)
            make.trailing.equalTo(importanceSelectBtn.snp.leading).offset(-standardMarkgin)
        }
        
        importanceSelectBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(standardMarkgin)
            make.bottom.trailing.equalToSuperview().offset(-standardMarkgin)
            make.width.equalTo(40)
        }
        
//        todoBoundLine.snp.makeConstraints { make in
//            make.centerY.equalToSuperview()
//            make.leading.equalTo(completeTodoBtn.snp.trailing)
//            make.width.equalTo(completeTodoLabel.text?.count)
//            make.height.equalTo(1)
//        }
        
//        completeOverwrapImage.snp.makeConstraints { make in
//            make.edges.equalTo(<#T##other: ConstraintRelatableTarget##ConstraintRelatableTarget#>)
//        }
        
        completeTodoLabel.snp.makeConstraints { make in
            make.edges.equalTo(todoTextField)
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
        print(string)
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
        }
        guard textField.text!.count < 20 else { return false }
        
            
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
