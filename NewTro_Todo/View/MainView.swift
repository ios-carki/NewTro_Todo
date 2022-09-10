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
        view.contentMode = .scaleToFill
        return view
    }()
    
    let coinImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "Coin")
        return view
    }()
    
    let coinCountLabel: UILabel = {
        let view = UILabel()
        view.font = .boldCoinCountLabel
        view.text = "00" + "\(Int.random(in: 100...10000))"
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
    
    //MARK: -- Todo
    let todoView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()
    
    let todoImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "TodoList")
        view.contentMode = .scaleToFill
        return view
    }()
    
    let todoLabel: UILabel = {
        let view = UILabel()
        view.text = "할 일 작성"
        view.font = .mainFont20
        view.textAlignment = .center
        return view
    }()
    //MARK: -- Todo
    
    //MARK: -- Habit
    let habitView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()
    
    let habitImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "HabitList")
        view.contentMode = .scaleToFill
        return view
    }()
    
    let habitLabel: UILabel = {
        let view = UILabel()
        view.text = "습관 관리"
        view.font = .mainFont20
        view.textAlignment = .center
        return view
    }()
    //MARK: -- Habit
    
    //MARK: -- QuickNote
    let quickNoteView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()
    
    let quickNoteImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "QuickNote")
        view.contentMode = .scaleToFill
        return view
    }()
    
    let quickNoteLabel: UILabel = {
        let view = UILabel()
        view.text = "퀵노트"
        view.font = .mainFont20
        view.textAlignment = .center
        return view
    }()
    //MARK: -- QuickNote
    
    override func configureUI() {
        todoView.addSubview(todoImage)
        todoView.addSubview(todoLabel)
        
        habitView.addSubview(habitImage)
        habitView.addSubview(habitLabel)
        
        quickNoteView.addSubview(quickNoteImage)
        quickNoteView.addSubview(quickNoteLabel)
        
        [todoView, habitView, quickNoteView, mainBackgroundImage, coinImage, coinCountLabel, heartImage1, heartImage2, heartImage3].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        
        mainBackgroundImage.snp.makeConstraints { make in
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
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
        
        //MARK: -- Todo
        todoView.snp.makeConstraints { make in
            make.top.equalTo(coinImage.snp.bottom).offset(10) //체크
            make.leading.equalTo(safeAreaLayoutGuide).offset(20)
            make.height.width.equalTo(80)
        }
        
        todoImage.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(todoView.safeAreaLayoutGuide)
        }
        
        todoLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(todoView.safeAreaLayoutGuide)
            make.top.equalTo(todoImage.snp.bottom)
            make.height.equalTo(20)
        }
        //MARK: -- Todo
        
        //MARK: -- Habit
        habitView.snp.makeConstraints { make in
            make.top.equalTo(coinImage.snp.bottom).offset(10)
            make.centerX.equalTo(safeAreaLayoutGuide)
            //make.leading.equalTo(todoView.snp.trailing).offset(40) //체크
            make.height.width.equalTo(80)
        }
        
        habitImage.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(habitView.safeAreaLayoutGuide)
        }
        
        habitLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(habitView.safeAreaLayoutGuide)
            make.top.equalTo(habitImage.snp.bottom)
            make.height.equalTo(20)
        }
        //MARK: -- Habit
        
        //MARK: -- QuickNote
        quickNoteView.snp.makeConstraints { make in
            make.top.equalTo(coinImage.snp.bottom).offset(10)
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-20)
            make.height.width.equalTo(80)
        }
        
        quickNoteImage.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(quickNoteView.safeAreaLayoutGuide)
        }
        
        quickNoteLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(quickNoteView.safeAreaLayoutGuide)
            make.top.equalTo(quickNoteImage.snp.bottom)
            make.height.equalTo(20)
        }
        //MARK: -- QuickNote
        
        
    }
}
