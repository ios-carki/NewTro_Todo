//
//  ImportanceViewCell.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/10/04.
//

import Foundation
import UIKit

import RealmSwift
import SnapKit

class ImportanceViewCell: UITableViewCell {
    static let identifier = "importanceViewCell"
    let mainView = ImportanceViewController()
    
    let localRealm = try! Realm()
    
    let completeView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    let todoLabel: UILabel = {
        let view = UILabel()
        
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
        contentView.addSubview(completeView)
        contentView.addSubview(todoLabel)
    }
    
    private func setLayout() {
        
        completeView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.equalTo(20)
        }
        
        todoLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalTo(completeView.snp.trailing).offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
}
