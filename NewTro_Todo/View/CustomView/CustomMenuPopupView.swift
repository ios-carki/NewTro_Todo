//
//  CustomMenuPopupView.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/20.
//

import Foundation
import UIKit

import SnapKit

class CustomMenuPopupView: BaseView {
    
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let detailTitleLabel: UILabel = {
        let view = UILabel()
        view.text = "세부 설정"
        view.textAlignment = .center
        view.backgroundColor = .blue
        view.font = .mainFont(size: 20)
        view.textColor = .white
        return view
    }()
    
    let cancelButton: UIButton = {
        let view = UIButton()
        view.titleLabel?.font = .mainFont(size: 20)
        view.setTitle("확인", for: .normal)
        view.backgroundColor = .gray
        return view
    }()
    
    let setImportanceButton: UIButton = {
        let view = UIButton()
        view.setTitle("[ 중요도 ]", for: .normal)
        view.setTitleColor(UIColor.yellow, for: .highlighted)
        view.titleLabel?.font = .mainFont(size: 20)
        view.titleLabel?.textColor = .white
        return view
    }()
    
    let setImportanceStatusLable: UILabel = {
        let view = UILabel()
        view.text = "...[ 하 ]"
        view.font = .mainFont(size: 20)
        view.textColor = .lightGray
        return view
    }()
    
    let setFavoriteButton: UIButton = {
        let view = UIButton()
        view.setTitle("[ 즐겨찾기 ]", for: .normal)
        view.setTitleColor(UIColor.yellow, for: .highlighted)
        view.titleLabel?.font = .mainFont(size: 20)
        view.titleLabel?.textColor = .white
        
        return view
    }()
    
    let setFavoriteStatusLabel: UILabel = {
        let view = UILabel()
        view.text = "...[ OFF ]"
        view.font = .mainFont(size: 20)
        view.textColor = .lightGray
        
        return view
    }()
    
    let deleteButton: UIButton = {
        let view = UIButton()
        view.setTitle("[ 삭제 ]", for: .normal)
        view.setTitleColor(UIColor.red, for: .normal)
        view.titleLabel?.font = .mainFont(size: 20)
        return view
    }()
    
    override func configureUI() {
        //뒷배경 흐리게
        self.backgroundColor = .black.withAlphaComponent(0.3)
        
        
        backgroundView.addSubview(detailTitleLabel)
        backgroundView.addSubview(cancelButton)
        backgroundView.addSubview(setImportanceButton)
        backgroundView.addSubview(setImportanceStatusLable)
        backgroundView.addSubview(setFavoriteButton)
        backgroundView.addSubview(setFavoriteStatusLabel)
        backgroundView.addSubview(deleteButton)
        
        [backgroundView].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.size.width / 1.5)
            make.height.equalTo(UIScreen.main.bounds.size.height / 2.5)
//            make.leading.equalToSuperview().offset(80)
//            make.top.equalToSuperview().offset(200)
        }
        
        detailTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        setImportanceButton.snp.makeConstraints { make in
            make.top.equalTo(detailTitleLabel.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(20)
        }
        
        setImportanceStatusLable.snp.makeConstraints { make in
            make.top.equalTo(detailTitleLabel.snp.bottom).offset(40)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(setImportanceButton)
        }
        
        setFavoriteButton.snp.makeConstraints { make in
            make.top.equalTo(setImportanceButton.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
        }
        
        setFavoriteStatusLabel.snp.makeConstraints { make in
            make.top.equalTo(setImportanceStatusLable.snp.bottom).offset(12)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(setFavoriteButton)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(setFavoriteButton.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
        }

        cancelButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.bottom.equalToSuperview()
        }
        
    }
}
