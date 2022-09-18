//
//  CalendarViewController.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/12.
//

import Foundation
import UIKit

import FSCalendar
import RealmSwift

final class CalendarViewController: BaseViewController {
    
    let mainView = CalendarView()
    
    let localRealm = try! Realm()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarSetting()
        let todoCount = localRealm.objects(Todo.self).count
        view.backgroundColor = .mainBackGroundColor
        print("저장데이터 확인용: ", localRealm.objects(Todo.self).count)
        mainView.todoCountLabel.text = "총 \(todoCount)건이 기록되어 있습니다."
    }
    
    func calendarSetting() {
        mainView.calendar.delegate = self
        mainView.calendar.dataSource = self
        mainView.calendar.appearance.eventDefaultColor = .red
    }
    
    func dateCounter(date: Date) -> Int {
        let selectedDate = date
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        
        let convertDate = dateFormatter.string(from: selectedDate)
        
        let dateFinder = localRealm.objects(Todo.self).where {
            $0.stringDate == convertDate
        }
        return dateFinder.count
    }
}

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        //선택된 날짜에 대한 투두 개수를 가져와야됨
        if dateCounter(date: date) == 0 {
            return 0
        } else {
            return 1
        }
    }
    
    //날짜 선택시
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        mainView.todoCountLabel.text = "총 \(dateCounter(date: date))건이 기록되어 있습니다."
    }
    
}

//data.regdate.map { date -> string}
