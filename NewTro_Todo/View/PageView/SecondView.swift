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
    
    let imageExplainLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.textAlignment = .center
        view.text = """
                    귀여운 도트 테마와
                    편리한 UI로
                    할 일을 관리해보세요!
                    """
        view.font = .mainFont(size: 30)
        return view
    }()
    
    override func configureUI() {
        [backGroundImage, pageTodoImage, imageExplainLabel].forEach {
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
        
        imageExplainLabel.snp.makeConstraints { make in
            make.top.equalTo(pageTodoImage.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
}
