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
    
    let calendar: FSCalendar = {
        let view = FSCalendar()
        view.backgroundColor = .systemCyan
        view.scope = .month
        view.locale = Locale(identifier: "ko-KR")
        view.appearance.headerTitleFont = .mainFont(size: 20)
        view.appearance.weekdayFont = .mainFont(size: 17)
        view.appearance.titleFont = .mainFont(size: 17)
        view.appearance.headerDateFormat = "YYYY년 MM월"
        view.appearance.headerTitleColor = .black
        view.appearance.todayColor = .systemGreen
        view.appearance.titleWeekendColor = .red
        view.appearance.titleDefaultColor = .white
        view.appearance.weekdayTextColor = .blue
        view.appearance.selectionColor = .purple
        return view
    }()
    
    //MARK: -- todo
    let calendarToDOView: UIView = {
        let view = UIView()
        
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
        view.text = "할 일 목록 개수"
        return view
    }()
    
    let todoCountLabel: UILabel = {
        let view = UILabel()
        view.text = "총 10건이 기록되어있습니다."
        view.textColor = .lightGray
        return view
    }()
    
    let todoMoveImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "chevron.right")
        return view
    }()
    //MARK: -- todo
    
    //MARK: -- habit
    let calendarHabitView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    let habitImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "HabitList")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let habitTextLabel: UILabel = {
        let view = UILabel()
        view.text = "습관 관리 목록 개수"
        view.font = .boldFont(size: 15)
        return view
    }()
    
    let habitCountLabel: UILabel = {
        let view = UILabel()
        view.text = "총 9건이 기록되어있습니다."
        view.font = .mainFont(size: 15)
        view.textColor = .lightGray
        return view
    }()
    
    let habitMoveImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "chevron.right")
        return view
    }()
    //MARK: -- habit
    
    //MARK: -- quickNote
    let calendarQuickNoteView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    let quickNoteImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "QuickNote")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let quickNoteTextLabel: UILabel = {
        let view = UILabel()
        view.text = "퀵노트 개수"
        return view
    }()
    
    let quickNoteCountLabel: UILabel = {
        let view = UILabel()
        view.text = "총 3건이 기록되어 있습니다."
        view.textColor = .lightGray
        return view
    }()
    
    let quickNoteMoveImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "chevron.right")
        return view
    }()
    //MARK: -- quickNote
    
    
    override func configureUI() {
        
        calendarToDOView.addSubview(todoImage)
        calendarToDOView.addSubview(todoTextLabel)
        calendarToDOView.addSubview(todoCountLabel)
        calendarToDOView.addSubview(todoMoveImage)
        
        calendarHabitView.addSubview(habitImage)
        calendarHabitView.addSubview(habitTextLabel)
        calendarHabitView.addSubview(habitCountLabel)
        calendarHabitView.addSubview(habitMoveImage)
        
        calendarQuickNoteView.addSubview(quickNoteImage)
        calendarQuickNoteView.addSubview(quickNoteTextLabel)
        calendarQuickNoteView.addSubview(quickNoteCountLabel)
        calendarQuickNoteView.addSubview(quickNoteMoveImage)
        
        [calendar, calendarToDOView, calendarHabitView, calendarQuickNoteView].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        
        calendar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(250)
        }
        
        //MARK: -- todo
        calendarToDOView.snp.makeConstraints { make in
            make.top.equalTo(calendar.snp.bottom)
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(120)
        }
        
        todoImage.snp.makeConstraints { make in
            make.top.leading.bottom.equalTo(calendarToDOView.safeAreaLayoutGuide)
            make.width.equalTo(70)
        }
        
        todoTextLabel.snp.makeConstraints { make in
            make.top.equalTo(calendarToDOView.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(todoImage.snp.trailing).offset(20)
        }
        
        todoCountLabel.snp.makeConstraints { make in
            make.top.equalTo(todoTextLabel.snp.bottom).offset(10)
            make.leading.equalTo(todoImage.snp.trailing).offset(20)
            make.bottom.equalTo(calendarToDOView.safeAreaLayoutGuide).offset(-20)
        }
        
        todoMoveImage.snp.makeConstraints { make in
            make.top.trailing.bottom.equalTo(calendarToDOView.safeAreaLayoutGuide)
            make.leading.equalTo(todoCountLabel.snp.trailing)
            make.width.equalTo(70)
        }
        //MARK: -- todo
        
        //MARK: -- habit
        calendarHabitView.snp.makeConstraints { make in
            make.top.equalTo(calendarToDOView.snp.bottom)
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(120)
        }
        
        habitImage.snp.makeConstraints { make in
            make.top.leading.bottom.equalTo(calendarHabitView.safeAreaLayoutGuide)
            make.width.equalTo(70)
        }
        
        habitTextLabel.snp.makeConstraints { make in
            make.top.equalTo(calendarHabitView.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(habitImage.snp.trailing).offset(20)
        }
        
        habitCountLabel.snp.makeConstraints { make in
            make.top.equalTo(habitTextLabel.snp.bottom).offset(10)
            make.leading.equalTo(habitImage.snp.trailing).offset(20)
            make.bottom.equalTo(calendarHabitView.safeAreaLayoutGuide).offset(-20)
        }
        
        habitMoveImage.snp.makeConstraints { make in
            make.top.trailing.bottom.equalTo(calendarHabitView.safeAreaLayoutGuide)
            make.leading.equalTo(habitCountLabel.snp.trailing)
            make.width.equalTo(70)
        }
        //MARK: -- habit
        
        //MARK: -- quickNote
        calendarQuickNoteView.snp.makeConstraints { make in
            make.top.equalTo(calendarHabitView.snp.bottom)
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(120)
        }
        
        quickNoteImage.snp.makeConstraints { make in
            make.top.leading.bottom.equalTo(calendarQuickNoteView.safeAreaLayoutGuide)
            make.width.equalTo(70)
        }
        
        quickNoteTextLabel.snp.makeConstraints { make in
            make.top.equalTo(calendarQuickNoteView.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(quickNoteImage.snp.trailing).offset(20)
        }
        
        quickNoteCountLabel.snp.makeConstraints { make in
            make.top.equalTo(quickNoteTextLabel.snp.bottom).offset(10)
            make.leading.equalTo(quickNoteImage.snp.trailing).offset(20)
            make.bottom.equalTo(calendarQuickNoteView.safeAreaLayoutGuide).offset(-20)
        }
        
        quickNoteMoveImage.snp.makeConstraints { make in
            make.top.trailing.bottom.equalTo(calendarQuickNoteView.safeAreaLayoutGuide)
            make.leading.equalTo(quickNoteCountLabel.snp.trailing)
            make.width.equalTo(70)
        }
        //MARK: -- quickNote
        
        
    }
}
