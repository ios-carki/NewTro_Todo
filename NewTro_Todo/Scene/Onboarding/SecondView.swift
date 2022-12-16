//
//  SecondView.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/06.
//

import Foundation
import UIKit

class SecondView: BasePageView {
    
    let backGroundImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "PageBackGround")
        view.contentMode = .scaleToFill
        return view
    }()
    
    let pageTodoImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "PageTwoImage")
        return view
    }()
    
    let page2_ImageExplainLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.textAlignment = .center
        view.text = "page2_ImageExplainLabel_Text".localized()
        view.font = .mainFont(size: 30)
        return view
    }()
    
    override func configureUI() {
        [backGroundImage, pageTodoImage, page2_ImageExplainLabel].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        
        backGroundImage.snp.makeConstraints { make in
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(10)
            make.height.equalTo(100)
        }
        
        pageTodoImage.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(50)
            make.centerX.equalToSuperview()
        }
        
        page2_ImageExplainLabel.snp.makeConstraints { make in
            make.top.equalTo(pageTodoImage.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
}
