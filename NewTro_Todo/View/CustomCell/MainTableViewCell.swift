//
//  MainTableViewCell.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/15.
//

import Foundation
import UIKit

import SnapKit

class MainTableViewCell: UITableViewCell {
    static let identifier = "tableCell"
    
    let todoTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "일정을 입력하세요."
        view.translatesAutoresizingMaskIntoConstraints = false
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
    }
    
    private func setLayout() {
        todoTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(20)
            make.trailing.bottom.equalToSuperview().offset(-8)
        }
    }
    
}
