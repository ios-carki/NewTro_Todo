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
    
    let versionView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    let versionInfoLabel: UILabel = {
        let view = UILabel()
        view.text = "versionInfoLabel_Text".localized()
        view.font = .mainFont(size: 16)
        return view
    }()
    
    let versionCreditLable: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.text = "versionCreditLabel_Text".localized()
        view.font = .mainFont(size: 16)
        return view
    }()
    
    let localNotiView: UIView = {
        let view = UIView()
        return view
    }()
    
    let localNotiImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "bell")
        view.contentMode = .scaleAspectFit
        view.tintColor = .black
        return view
    }()
    
    let localNotiLabel: UILabel = {
        let view = UILabel()
        view.text = "알림"
        view.font = .mainFont(size: 20)
        return view
    }()
    
    let localNotiSwitch: UISwitch = {
        let view = UISwitch()
        return view
    }()
    
    let tableView: UITableView = {
        let view = UITableView()
        view.isScrollEnabled = false
        view.backgroundColor = .mainBackGroundColor
        view.separatorStyle = .none
        return view
    }()
    
    /*
     
     let imageView: UIImageView = {
         let view = UIImageView()
         view.contentMode = .scaleAspectFit
         return view
     }()
     
     let versionInfoLabel: UILabel = {
         let view = UILabel()
         view.text = "현재 버전"
         view.font = .mainFont(size: 16)
         return view
     }()
     
     let programCreditLable: UILabel = {
         let view = UILabel()
         view.numberOfLines = 0
         view.text = """
         개발자: Carki
         디자이너: Carki
         """
         return view
     }()
     */
    override func configureUI() {
        versionView.addSubview(versionInfoLabel)
        versionView.addSubview(versionCreditLable)
        localNotiView.addSubview(localNotiLabel)
        localNotiView.addSubview(localNotiSwitch)
        
        [versionView, localNotiImage, localNotiView, backGroundImage, tableView].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        
        backGroundImage.snp.makeConstraints { make in
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.bottom.equalToSuperview().offset(10)
            make.height.equalTo(100)
        }
        
        versionView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(150)
        }
        
        versionInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.centerX.equalTo(safeAreaLayoutGuide)
        }
        
        versionCreditLable.snp.makeConstraints { make in
            make.top.equalTo(versionInfoLabel.snp.bottom)
            make.centerX.equalTo(safeAreaLayoutGuide)
        }
        
        localNotiImage.snp.makeConstraints { make in
            make.top.equalTo(versionView.snp.bottom)
            make.leading.equalTo(safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(localNotiView.snp.leading)
            make.height.equalTo(localNotiView.snp.height)
        }
        
        localNotiView.snp.makeConstraints { make in
            make.top.equalTo(versionView.snp.bottom)
            make.trailing.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(50)
        }
        
        localNotiLabel.snp.makeConstraints { make in
            make.centerY.equalTo(localNotiView)
            make.leading.equalTo(localNotiView.safeAreaLayoutGuide).offset(17)
        }
        
        localNotiSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(localNotiView)
            make.trailing.equalTo(localNotiView.safeAreaLayoutGuide).offset(-20)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(localNotiView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(backGroundImage.snp.top)
        }
    }
}

//렘 버전을 마스터로 다시설치
//너가 보내준 코드 다시해보기
