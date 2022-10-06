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
import SwiftUI

class MainTableViewCell: UITableViewCell {
    static let identifier = "tableCell"
    
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
    
    let todoTextView: UITextView = {
        let view = UITextView()
        view.textColor = .black
        view.isHidden = false
        view.backgroundColor = .mainBackGroundColor
        view.font = .mainFont(size: 16)
        view.translatesAutoresizingMaskIntoConstraints = true
        view.isScrollEnabled = false
        view.isEditable = true
        view.returnKeyType = .next
        view.sizeToFit()
        view.textContainer.maximumNumberOfLines = 5
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
        view.numberOfLines = 0
        view.isHidden = true
        view.textColor = .white
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
        contentView.addSubview(todoTextView)
        contentView.addSubview(importanceSelectBtn)
        contentView.addSubview(completeTodoLabel)
//        contentView.addSubview(todoBoundLine)
    }
    
    private func setLayout() {
        let standardMarkgin = 8
        
        completeTodoBtn.snp.makeConstraints { make in
//            make.top.leading.equalToSuperview().offset(standardMarkgin)
//            make.bottom.equalToSuperview().offset(-standardMarkgin)
            make.leading.equalToSuperview().offset(standardMarkgin)
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(50)
        }
        
        todoTextView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(standardMarkgin)
            make.bottom.equalToSuperview().offset(-standardMarkgin)
            make.leading.equalTo(completeTodoBtn.snp.trailing).offset(standardMarkgin)
            make.trailing.equalTo(importanceSelectBtn.snp.leading).offset(-standardMarkgin)
        }
        
        importanceSelectBtn.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(standardMarkgin)
//            make.bottom.trailing.equalToSuperview().offset(-standardMarkgin)
            make.trailing.equalToSuperview().offset(-standardMarkgin)
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(50)
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
            make.edges.equalTo(todoTextView)
        }
    }
}
