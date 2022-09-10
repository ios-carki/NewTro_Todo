//
//  FirstView.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/06.
//

import Foundation
import UIKit

import SnapKit

class FirstView: BasePageView {
    
    let pageLabel1: UILabel = {
        let view = UILabel()
        view.text = "도트감성"
        view.alpha = 0
        view.textAlignment = .center
        view.font = .mainFont30
        UIView.animate(withDuration: 3) {
            view.alpha = 1
        }
        return view
    }()
    
    let pageLabel2: UILabel = {
        let view = UILabel()
        view.text = "할 일 목록 앱"
        view.alpha = 0
        view.textAlignment = .center
        view.font = .mainFont50
        UIView.animate(withDuration: 3, delay: 1) {
            view.alpha = 1
        }
        return view
    }()
    
    let pageLabel3: UILabel = {
        let view = UILabel()
        view.text = """
                    New-Tro
                    ToDo!
                    """
        view.alpha = 0
        view.textColor = .yellow
        view.numberOfLines = 0
        view.textAlignment = .center
        view.font = .boldFont60
        UIView.animate(withDuration: 3, delay: 1.5) {
            view.alpha = 1
        }
        return view
    }()
    
    let swipeImage: UIImageView = {
        let view = UIImageView()
//        view.image = UIImage(named: <#T##String#>)
        return view
    }()
    
    let backGroundImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "Page1BackGround")
        view.contentMode = .scaleToFill
        return view
    }()
    
    override func configureUI() {
        [pageLabel1, pageLabel2, pageLabel3, backGroundImage].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        
        pageLabel1.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(100)
            make.leading.equalTo(safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-20)
        }
        
        pageLabel2.snp.makeConstraints { make in
            make.top.equalTo(pageLabel1.snp.bottom).inset(4)
            make.leading.equalTo(safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-20)
        }
        
        pageLabel3.snp.makeConstraints { make in
            make.top.equalTo(pageLabel2.snp.bottom).inset(4)
            make.leading.equalTo(safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-20)
        }
        
        backGroundImage.snp.makeConstraints { make in
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(10)
            make.height.equalTo(214)
        }
    }
}
