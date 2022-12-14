//
//  CalendarView.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/12.
//

import Foundation

import FSCalendar
import SnapKit

final class CalendarView: BaseView {
    
    let calendarViewBackgroundImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "CalendarViewBackGround")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let calendar: FSCalendar = {
        let view = FSCalendar()
        view.backgroundColor = .mainBackGroundColor
        view.scope = .month
        view.locale = Locale.current//(identifier: "ko-KR")
        view.appearance.headerTitleFont = .mainFont(size: 20)
        view.appearance.weekdayFont = .mainFont(size: 17)
        view.appearance.titleFont = .mainFont(size: 17)
        view.appearance.headerDateFormat = "headerDateFormat".localized()
        view.appearance.headerTitleColor = .black
        view.appearance.todayColor = .systemGreen
        view.appearance.titleWeekendColor = .calendarWeekendColor
        view.appearance.titleDefaultColor = .white
        view.appearance.weekdayTextColor = .calendarWeekdayColor
        view.appearance.selectionColor = .purple
        view.appearance.eventDefaultColor = .calendarWeekendColor
        view.appearance.eventSelectionColor = .calendarWeekendColor
        return view
    }()
    
    //MARK: -- todo
    let calendarToDOView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainBackGroundColor
        shadowEffect(view: view)
        return view
    }()
    
    let todoImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "TodoList")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let todoTextLabel: UILabel = {
        let view = UILabel()
        view.text = "todoTextLabel_Text".localized()
        view.font = .mainFont(size: 20)
        return view
    }()
    
    let todoCountLabel: UILabel = {
        let view = UILabel()
        view.text = "todoCountLabel_Text".localized()
        view.font = .mainFont(size: 15)
        view.textColor = .lightGray
        return view
    }()
    
    let todoMoveImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "chevron.right")
        return view
    }()
    //MARK: -- todo
    
    //MARK: -- quickNote
//    let calendarQuickNoteView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .mainBackGroundColor
//        shadowEffect(view: view)
//        return view
//    }()
//
//    let quickNoteImage: UIImageView = {
//        let view = UIImageView()
//        view.image = UIImage(named: "QuickNote")
//        view.contentMode = .scaleAspectFit
//        return view
//    }()
//
//    let quickNoteTextLabel: UILabel = {
//        let view = UILabel()
//        view.text = "????????? ??????"
//        return view
//    }()
//
//    let quickNoteCountLabel: UILabel = {
//        let view = UILabel()
//        view.text = "??? 3?????? ???????????? ????????????."
//        view.textColor = .lightGray
//        return view
//    }()
//
//    let quickNoteMoveImage: UIImageView = {
//        let view = UIImageView()
//        view.image = UIImage(systemName: "chevron.right")
//        return view
//    }()
//    //MARK: -- quickNote
    
    
    override func configureUI() {
        
        calendarToDOView.addSubview(todoImage)
        calendarToDOView.addSubview(todoTextLabel)
        calendarToDOView.addSubview(todoCountLabel)
        calendarToDOView.addSubview(todoMoveImage)
        
        
//        calendarQuickNoteView.addSubview(quickNoteImage)
//        calendarQuickNoteView.addSubview(quickNoteTextLabel)
//        calendarQuickNoteView.addSubview(quickNoteCountLabel)
//        calendarQuickNoteView.addSubview(quickNoteMoveImage)
        
        [calendarViewBackgroundImage, calendar, calendarToDOView].forEach { // ????????? calendarQuickNoteView ??????
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        let bounds = UIScreen.main.bounds
        
        calendarViewBackgroundImage.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(10)
            make.height.equalTo(100)
        }
        
        calendar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(250)
        }
        
        //MARK: -- todo
        calendarToDOView.snp.makeConstraints { make in
            make.top.equalTo(calendar.snp.bottom).offset(4)
            make.leading.equalTo(safeAreaLayoutGuide).offset(8)
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-8)
            make.height.equalTo(80)
        }
        
        todoImage.snp.makeConstraints { make in
            make.top.leading.bottom.equalTo(calendarToDOView.safeAreaLayoutGuide)
            make.width.equalTo(50)
        }
        
        todoTextLabel.snp.makeConstraints { make in
            make.top.equalTo(calendarToDOView.safeAreaLayoutGuide).offset(12)
            make.leading.equalTo(todoImage.snp.trailing).offset(20)
        }
        
        todoCountLabel.snp.makeConstraints { make in
            make.top.equalTo(todoTextLabel.snp.bottom).offset(8)
            make.leading.equalTo(todoImage.snp.trailing).offset(20)
            make.bottom.equalTo(calendarToDOView.safeAreaLayoutGuide).offset(-8)
        }
        
        //MARK: -- todo
        
        //MARK: -- quickNote
//        calendarQuickNoteView.snp.makeConstraints { make in
//            make.top.equalTo(calendarToDOView.snp.bottom).offset(12)
//            make.leading.equalTo(safeAreaLayoutGuide).offset(8)
//            make.trailing.equalTo(safeAreaLayoutGuide).offset(-8)
//            make.height.equalTo(80)
//        }
//
//        quickNoteImage.snp.makeConstraints { make in
//            make.top.leading.bottom.equalTo(calendarQuickNoteView.safeAreaLayoutGuide)
//            make.width.equalTo(50)
//        }
//
//        quickNoteTextLabel.snp.makeConstraints { make in
//            make.top.equalTo(calendarQuickNoteView.safeAreaLayoutGuide).offset(12)
//            make.leading.equalTo(quickNoteImage.snp.trailing).offset(20)
//        }
//
//        quickNoteCountLabel.snp.makeConstraints { make in
//            make.top.equalTo(quickNoteTextLabel.snp.bottom).offset(8)
//            make.leading.equalTo(quickNoteImage.snp.trailing).offset(20)
//            make.bottom.equalTo(calendarQuickNoteView.safeAreaLayoutGuide).offset(-8)
//        }
//
////        quickNoteMoveImage.snp.makeConstraints { make in
////            make.top.trailing.bottom.equalTo(calendarQuickNoteView.safeAreaLayoutGuide)
////            make.leading.equalTo(quickNoteCountLabel.snp.trailing)
////            make.width.equalTo(70)
////        }
//        //MARK: -- quickNote
//
        
    }
}
