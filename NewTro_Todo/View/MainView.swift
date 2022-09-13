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
        view.font = .boldFont(size: 20)
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
    
    //MARK: -- Todobtn
    let todoView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
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
        view.font = .mainFont(size: 20)
        view.textAlignment = .center
        return view
    }()
    //MARK: -- Todobtn
    
    //MARK: -- Habitbtn
    let habitView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
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
        view.font = .mainFont(size: 20)
        view.textAlignment = .center
        return view
    }()
    //MARK: -- Habitbtn
    
    //MARK: -- QuickNotebtn
    let quickNoteView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
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
        view.font = .mainFont(size: 20)
        view.textAlignment = .center
        return view
    }()
    //MARK: -- QuickNotebtn
    
    let segmentControl: UISegmentedControl = {
        let todo: String = "할 일 목록"
        let habit: String = "습관 관리 목록"
        let quickNote: String = "퀵노트 목록"
        let font = UIFont.mainFont(size: 20)
        let attributes = [NSAttributedString.Key.font: font]
        
        //글꼴 바꾸기 체크
        let attributedTodoString = NSMutableAttributedString(string: todo, attributes: attributes)
        let attributedHabitString = NSAttributedString(string: habit, attributes: attributes)
        let attributedQuickNoteString = NSAttributedString(string: quickNote, attributes: attributes)
        
        let view = UISegmentedControl(items: [attributedTodoString, "습관 관리 목록", "퀵노트 목록"])
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor.mainBackGroundColor.cgColor
        return view
    }()
    
    let segTopExtendButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        view.tintColor = .black
        view.backgroundColor = .white
        return view
    }()
    
    let segTopSearchBar: UISearchBar = {
        let view = UISearchBar()
        
        return view
    }()
    
    //MARK: -- TodoSeg
    let todoSegView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    let todoTableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .red
        return view
    }()
    //MARK: -- TodoSeg
    
    //MARK: -- HabitSeg
    let habitSegView: UIView = {
        let view = UIView()
        view.backgroundColor = .orange
        return view
    }()
    
    let habitTableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .orange
        return view
    }()
    //MARK: -- HabitSeg
    
    //MARK: -- QuickNoteSeg
    let quickNoteSegView: UIView = {
        let view = UIView()
        view.backgroundColor = .yellow
        return view
    }()
    
    let quickNoteTableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .yellow
        return view
    }()
    //MARK: -- QuickNoteSeg
    
    override func configureUI() {
        todoView.addSubview(todoImage)
        todoView.addSubview(todoLabel)
        todoSegView.addSubview(todoTableView)
        
        habitView.addSubview(habitImage)
        habitView.addSubview(habitLabel)
        habitSegView.addSubview(habitTableView)
        
        quickNoteView.addSubview(quickNoteImage)
        quickNoteView.addSubview(quickNoteLabel)
        quickNoteSegView.addSubview(quickNoteTableView)
        
        //바텀뷰 - 버튼, 서치바, 테이블뷰 들어갈 뷰 3개
        bottomView.addSubview(segTopExtendButton)
        bottomView.addSubview(segTopSearchBar)
        bottomView.addSubview(todoSegView)
        bottomView.addSubview(habitSegView)
        bottomView.addSubview(quickNoteSegView)
        
        [todoView, habitView, quickNoteView, mainBackgroundImage, coinImage, coinCountLabel, heartImage1, heartImage2, heartImage3, segmentControl, bottomView].forEach {
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
        
        segmentControl.snp.makeConstraints { make in
            make.top.equalTo(todoView.snp.bottom).offset(30)
            make.leading.equalTo(safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-20)
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(30)
        }
        
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(segmentControl.snp.bottom).offset(20)
            make.leading.equalTo(safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-20)
            make.bottom.equalTo(mainBackgroundImage.snp.top)
        }
        
        segTopExtendButton.snp.makeConstraints { make in
            make.top.equalTo(bottomView.safeAreaLayoutGuide)
            make.centerX.equalTo(bottomView.safeAreaLayoutGuide)
            make.width.equalTo(40)
        }

        segTopSearchBar.snp.makeConstraints { make in
            make.top.equalTo(segTopExtendButton.snp.bottom)
            make.leading.trailing.equalTo(bottomView.safeAreaLayoutGuide)
            make.height.equalTo(40)
        }

        todoSegView.snp.makeConstraints { make in
            make.top.equalTo(segTopSearchBar.snp.bottom)
            make.leading.trailing.bottom.equalTo(bottomView.safeAreaLayoutGuide)
        }
        
        todoTableView.snp.makeConstraints { make in
            make.edges.equalTo(todoSegView)
        }

        habitSegView.snp.makeConstraints { make in
            make.top.equalTo(segTopSearchBar.snp.bottom)
            make.leading.trailing.bottom.equalTo(bottomView.safeAreaLayoutGuide)
        }
        
        habitTableView.snp.makeConstraints { make in
            make.edges.equalTo(habitSegView)
        }

        quickNoteSegView.snp.makeConstraints { make in
            make.top.equalTo(segTopSearchBar.snp.bottom)
            make.leading.trailing.bottom.equalTo(bottomView.safeAreaLayoutGuide)
        }
        
        quickNoteTableView.snp.makeConstraints { make in
            make.edges.equalTo(quickNoteSegView)
        }
    }
}
