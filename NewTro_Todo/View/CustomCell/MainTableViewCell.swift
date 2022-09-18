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
    
    let todoTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "일정을 입력하세요."
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.returnKeyType = .done
        return view
    }()
    
    let storedView: UIView = {
        let view = UIView()
        view.backgroundColor = .yellow
        
        return view
    }()
    
    let importanceView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        
        return view
    }()
    
    let importanceSelectBtn: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        view.tintColor = .black
        return view
    }()
    
//    let importanceLabel: UILabel = {
//        let view = UILabel()
//        view.numberOfLines = 0
//        view.text = """
//                    중요도
//                    선택
//                    """
//        view.font = .mainFont(size: 10)
//        view.textAlignment = .center
//        return view
//    }()
//
//    let setImportanceView: UIStackView = {
//        let view = UIStackView()
//        view.axis = .horizontal
//        view.distribution = .fillEqually
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.alignment = .fill
//        view.spacing = 4
//        return view
//    }()
//
//    let importanceSelectedBtn: UIButton = {
//        let view = UIButton()
//        view.backgroundColor = .mainBackGroundColor
//        view.setTitle("중요도 선택", for: .normal)
//        view.layer.borderWidth = 1
//        view.layer.borderColor = UIColor.mainBackGroundColor.cgColor
//        view.layer.cornerRadius = 10
//        return view
//    }()
//
//    let importanceSelectedLabel: UILabel = {
//        let view = UILabel()
//        view.backgroundColor = .mainBackGroundColor
//        view.text = "선택한 중요도"
//        view.layer.borderWidth = 1
//        view.layer.borderColor = UIColor.mainBackGroundColor.cgColor
//        view.layer.cornerRadius = 10
//        view.clipsToBounds = true
//        return view
//    }()
    
    //중요도 상
//    let setImportance2Btn: UIButton = {
//        let view = UIButton()
//        view.backgroundColor = .mainBackGroundColor
//        view.layer.borderColor = UIColor.black.cgColor
//        view.layer.borderWidth = 1
//        view.layer.cornerRadius = 10
//        view.setTitle("중요도 상", for: .normal)
//        return view
//    }()
//
//    //중요도 중
//    let setImportance1Btn: UIButton = {
//        let view = UIButton()
//        view.backgroundColor = .mainBackGroundColor
//        view.layer.borderColor = UIColor.black.cgColor
//        view.layer.borderWidth = 1
//        view.layer.cornerRadius = 10
//        view.setTitle("중요도 중", for: .normal)
//        return view
//    }()
//
//    //중요도 하
//    let setImportance0Btn: UIButton = {
//        let view = UIButton()
//        view.backgroundColor = .mainBackGroundColor
//        view.layer.borderColor = UIColor.black.cgColor
//        view.layer.borderWidth = 1
//        view.layer.cornerRadius = 10
//        view.setTitle("중요도 하", for: .normal)
//        return view
//    }()
    
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
    
    //중요도2 버튼 클릭
    //버튼2개 배경 회색으로
    //데이터상 중요도 2로 변경
    //배열안에 기능 넣어서 순회
//    @objc func importance2ButtonClicked() {
//        setImportance2Btn.backgroundColor = .mainBackGroundColor
//        setImportance1Btn.backgroundColor = .lightGray
//        setImportance0Btn.backgroundColor = .lightGray
//        importanceView.backgroundColor = .red
//        print("중요도2 눌렸음")
//
//    }
//
//    @objc func importance1ButtonClicked() {
//        setImportance1Btn.backgroundColor = .mainBackGroundColor
//        setImportance2Btn.backgroundColor = .lightGray
//        setImportance0Btn.backgroundColor = .lightGray
//        importanceView.backgroundColor = .mainBackGroundColor
//        print("중요도1 눌렸음")
//
//    }
//
//    @objc func importance0ButtonClicked() {
//        setImportance0Btn.backgroundColor = .mainBackGroundColor
//        setImportance1Btn.backgroundColor = .lightGray
//        setImportance2Btn.backgroundColor = .lightGray
//        importanceView.backgroundColor = .white
//        print("중요도0 눌렸음")
//
//    }
//
    private func configure() {
        
        contentView.addSubview(storedView)
        contentView.addSubview(importanceView)
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
        
        storedView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.equalTo(10)
        }
        
        importanceView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalTo(storedView.snp.trailing).offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.equalTo(10)
        }
        
        todoTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalTo(importanceView.snp.trailing).offset(12)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        importanceSelectBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalTo(todoTextField.snp.trailing).offset(8)
            make.bottom.trailing.equalToSuperview().offset(-8)
        }
        
//        importanceLabel.snp.makeConstraints { make in
//            make.top.equalTo(todoTextField.snp.bottom).offset(8)
//            make.leading.equalTo(importanceView.snp.trailing).offset(8)
//            make.bottom.equalToSuperview().offset(-8)
//        }
//
//        setImportanceView.snp.makeConstraints { make in
//            make.top.equalTo(todoTextField.snp.bottom).offset(8)
//            make.leading.equalTo(importanceLabel.snp.trailing).offset(8)
//            make.trailing.bottom.equalToSuperview().offset(-8)
//        }
    }
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
        //셀에 해당되는 id값을 받아와서 그 id값에 해당되는 text를 변경
        //옵셔널처리
        let findTextField = localRealm.objects(Todo.self).where {
            $0.objectID == id!
        }.first
        try! localRealm.write {
            findTextField?.setValue(textField.text!, forKey: "todo")
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
