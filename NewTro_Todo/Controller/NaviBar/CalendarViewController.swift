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
    let mainVC = MainViewController()
    //클로저
    //델리게이트
    //노티
    
    var selectedDate = Date()
    let dateFormat = DateFormatter()
    
    //방법2
    //받아올 날자
    var dateCompletionHandler: ( () -> () )?
    
    //방법1. 전역변수 선언
//    var testDate: Date?
    
    
    let localRealm = try! Realm()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .mainBackGroundColor
        calendarSetting()
        mainView.todoCountLabel.text = "총 \(dateCounter(date: selectedDate))건이 기록되어 있습니다."
        todoListViewClicked()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        NotificationCenter.default.post(name: NSNotification.Name("DismissCalendarView"), object: nil, userInfo: nil)
//    }
//    
    /*
     func todoTapGesture() {
         let tapGesture = UITapGestureRecognizer(target: self, action: #selector(todoList))
         mainView.todoView.addGestureRecognizer(tapGesture)
     }
     
     @objc func todoList() {
         print("투두 클릭")
     }
     */
    func todoListViewClicked() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(todoListViewTapGesture))
        mainView.calendarToDOView.addGestureRecognizer(gesture)
    }
    
    @objc func todoListViewTapGesture() {
        dateFormat.dateFormat = "yyyy년 MM월 dd일"
        let convertDate = dateFormat.string(from: selectedDate)
        
        print("캘린더 투두 클릭됨: ", convertDate)
        
        //선택된 날짜로 이동하게함
        //그럼 메인에서 화살표 함수를 찾아서 오늘 날짜를 기준으로 쓰는 변수에 값전달을 해야됨
        //아니면 어제 셀 삭제에서 구현한것과 마찬가지로
        //노티피케이션을 이용해야됨.
        self.dateCompletionHandler?()
        dismiss(animated: true)
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
        self.selectedDate = date
    }
    
}

//data.regdate.map { date -> string}
