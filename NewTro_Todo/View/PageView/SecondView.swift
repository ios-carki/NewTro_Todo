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
    
    override func configureUI() {
        [backGroundImage].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        
        backGroundImage.snp.makeConstraints { make in
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(10)
            make.height.equalTo(100)
        }
    }
}
