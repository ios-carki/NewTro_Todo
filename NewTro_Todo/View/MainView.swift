//
//  MainView.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/09.
//

import Foundation
import UIKit

import SnapKit

class MainView: BaseView {
    
    let mainBackgroundImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "MainBackGround")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let coinImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "Coin")
        return view
    }()
    
    let coinCountLabel: UILabel = {
        let view = UILabel()
        
        view.font = .boldFont(size: 20)
        view.text = dateFormat(formatType: "yyMMdd")
        view.textColor = .coinCountLabelColor
        return view
    }()
    
    let heartImage1: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "Heart")
        return view
    }()
    
    let heartImage2: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "Heart")
        return view
    }()
    
    let heartImage3: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "Heart")
        return view
    }()
    
    //MARK: -- bottomView
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainBackGroundColor
        
        return view
    }()
    
    //추가
    let btnStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .equalSpacing
        view.spacing = 0
        return view
    }()
    
    let todoPlusView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainBackGroundColor
    
        return view
    }()
    
    let todoPlusImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "TodoBtn")
        view.contentMode = .scaleToFill
        return view
    }()
    
    let quickNoteView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainBackGroundColor
    
        return view
    }()
    
    let quickNoteImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "NoteBtn")
        view.contentMode = .scaleToFill
        return view
    }()
    //MARK: -- QuickNotebtn
    
    let leftButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "YesterDayBtn"), for: .normal)
        view.imageView?.contentMode = .scaleToFill
        return view
    }()
    
    let datePickBtn: UIButton = {
        let view = UIButton()
        view.setTitle(dateFormat(formatType: "yyyy년 MM월 dd일"), for: .normal)
        view.titleLabel?.font = .boldFont(size: 17)
        view.titleLabel?.textAlignment = .center
        view.titleLabel?.textColor = .black
        return view
    }()
    
    let rightButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "TomorrowBtn"), for: .normal)
        view.imageView?.contentMode = .scaleToFill
        return view
    }()
    
    let boundaryLine: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    let tableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .mainBackGroundColor
        return view
    }()
    //MARK: -- bottomView
    
//    func collectionViewConfigure() {
//        todoCollectionView.
//    }
    
    override func configureUI() {
        bottomView.addSubview(leftButton)
        bottomView.addSubview(datePickBtn)
        bottomView.addSubview(rightButton)
        bottomView.addSubview(btnStackView)
        bottomView.addSubview(boundaryLine)
        bottomView.addSubview(tableView)
        
        todoPlusView.addSubview(todoPlusImage)
        quickNoteView.addSubview(quickNoteImage)
        
        [todoPlusView, quickNoteView].map {
            self.btnStackView.addArrangedSubview($0)
        }
        
        [bottomView, mainBackgroundImage, coinImage, coinCountLabel, heartImage1, heartImage2, heartImage3].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        
        mainBackgroundImage.snp.makeConstraints { make in
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.bottom.equalToSuperview().offset(10)
            make.height.equalTo(100)
        }
        
        coinImage.snp.makeConstraints { make in
            make.top.leading.equalTo(safeAreaLayoutGuide).offset(5)
            make.height.width.equalTo(50)
        }
        
        coinCountLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(19)
            make.leading.equalTo(coinImage.snp.trailing)
        }
        
        heartImage1.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(5)
            make.trailing.equalTo(heartImage2.snp.leading).offset(20)
            make.height.width.equalTo(50)
        }
        
        heartImage2.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(5)
            make.trailing.equalTo(heartImage3.snp.leading).offset(20)
            make.height.width.equalTo(50)
        }
        
        heartImage3.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(5)
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-5)
            make.height.width.equalTo(50)
        }
        
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(heartImage1.snp.bottom).offset(12)
            make.leading.equalTo(safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-20)
            make.bottom.equalTo(mainBackgroundImage.snp.top)
        }
        
        leftButton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(12)
            make.bottom.equalTo(boundaryLine.snp.top).offset(-8)
            make.height.width.equalTo(50)
        }
        
        datePickBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(boundaryLine.snp.top).offset(-8)
        }
        
        rightButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.bottom.equalTo(boundaryLine.snp.top).offset(-8)
            make.trailing.equalToSuperview().offset(-12)
            make.height.width.equalTo(50)
        }
        
        boundaryLine.snp.makeConstraints { make in
            make.leading.equalTo(bottomView.safeAreaLayoutGuide).offset(8)
            make.trailing.equalTo(bottomView.safeAreaLayoutGuide).offset(-8)
            make.height.equalTo(1)
        }
        
        btnStackView.snp.makeConstraints { make in
            make.centerX.equalTo(bottomView)
            make.top.equalTo(boundaryLine.snp.bottom)
            make.height.equalTo(heartImage1.snp.height)
        }
        
        todoPlusView.snp.makeConstraints { make in
            make.height.width.equalTo(50)
        }
        
        todoPlusImage.snp.makeConstraints { make in
            make.edges.equalTo(todoPlusView.safeAreaLayoutGuide)
        }
        
        quickNoteView.snp.makeConstraints { make in
            make.height.width.equalTo(50)
        }
        
        quickNoteImage.snp.makeConstraints { make in
            make.edges.equalTo(quickNoteView.safeAreaLayoutGuide)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(btnStackView.snp.bottom)
            make.leading.trailing.bottom.equalTo(bottomView.safeAreaLayoutGuide)
        }
        
    }
    
}
