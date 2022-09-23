//
//  SettingView.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/12.
//

import Foundation
import UIKit

import SnapKit

final class SettingView: BaseView {
    
    let backGroundImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "SettingBackGround")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let tableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .mainBackGroundColor
        return view
    }()
    
    override func configureUI() {
        [backGroundImage, tableView].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        
        backGroundImage.snp.makeConstraints { make in
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.bottom.equalToSuperview().offset(10)
            make.height.equalTo(100)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(backGroundImage.snp.top)
        }
    }
}
