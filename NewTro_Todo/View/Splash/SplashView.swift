//
//  SplashView.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/12/07.
//

import UIKit

import SnapKit

final class SplashView: BaseView {
    
    let splashLabel: UILabel = {
        let view = UILabel()
        view.textColor = .yellow
        view.textAlignment = .center
        view.font = .mainFont(size: 50)
        view.numberOfLines = 2
        return view
    }()
    
    override func configureUI() {
        self.addSubview(splashLabel)
        
        self.backgroundColor = .mainBackGroundColor
    }
    
    override func setConstraints() {
        
        splashLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
