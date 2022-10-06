//
//  ImportanceView.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/10/04.
//

import Foundation
import UIKit

final class ImportanceView: BaseView {
    
    let importanceTableView: UITableView = {
        let view = UITableView()
        
        return view
    }()
    
    let importanceViewBackgroundImage: UIImageView = {
        let view = UIImageView()
        
        return view
    }()
    
    
    override func configureUI() {
        [importanceTableView, importanceViewBackgroundImage].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        
        importanceViewBackgroundImage.snp.makeConstraints { make in
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.bottom.equalToSuperview().offset(10)
            make.height.equalTo(100)
        }
        
        importanceTableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(importanceViewBackgroundImage.snp.top)
        }
    }
}
