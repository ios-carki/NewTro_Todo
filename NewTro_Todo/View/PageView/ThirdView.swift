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
    
    let pageNoteImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "PageThreeImage")
        return view
    }()
    
    let imageExplainLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = .mainFont(size: 30)
        view.textAlignment = .center
        view.text = """
                    도트 텍스트의 편리한
                    메모장도 이용해 보세요!
                    """
        return view
    }()
    
    let signupButton: UIButton = {
        let view = UIButton()
        view.setTitle("시작하기", for: .normal)
        view.setTitleColor(UIColor.black, for: .normal)
        view.backgroundColor = .white.withAlphaComponent(0.5)
        view.titleLabel?.font = .mainFont(size: 30)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    override func configureUI() {
        [backGroundImage, signupButton, pageNoteImage, imageExplainLabel].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        
        pageNoteImage.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(30)
            make.centerX.equalToSuperview()
            make.height.equalTo(300)
        }
        
        imageExplainLabel.snp.makeConstraints { make in
            make.top.equalTo(pageNoteImage.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
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
