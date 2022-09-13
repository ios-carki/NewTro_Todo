//
//  ThirdView.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/06.
//

import Foundation
import UIKit

class ThirdView: BasePageView {
    
    let backGroundImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "Page3BackGround")
        view.contentMode = .scaleToFill
        return view
    }()
    
    let signupButton: UIButton = {
        let view = UIButton()
        view.setTitle("시작하기", for: .normal)
        view.titleLabel?.font = .mainFont(size: 30)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    override func configureUI() {
        [backGroundImage, signupButton].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        
        signupButton.snp.makeConstraints { make in
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-120)
            make.width.equalTo(180)
        }
        
        backGroundImage.snp.makeConstraints { make in
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(10)
            make.height.equalTo(214)
        }
    }
}
