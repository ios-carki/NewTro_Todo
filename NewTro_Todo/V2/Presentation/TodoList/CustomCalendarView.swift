//
//  CustomCalendarView.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/15/24.
//
import UIKit
import SwiftUI

import Factory
import FSCalendar
import RealmSwift


struct CustomCalendarView: UIViewRepresentable {
    @Injected(\.getAllTodoDateUseCase) private var getAllTodoDateUseCase
    @State private var allDate: [Date] = []
    
    @Binding var selectedDate: Date
    @Binding var todoData: [TodoDomain]
    @Binding var pageCurrent: Date
    var action: () -> ()
    
    func makeUIView(context: Context) -> FSCalendar {
        //Appearence
        let view = FSCalendar()
        
        view.register(CalendarCell.self, forCellReuseIdentifier: CalendarCell.description())
        view.delegate = context.coordinator
        view.dataSource = context.coordinator
        
        view.backgroundColor = .mainBackGroundColor
        view.scope = .month
        view.locale = Locale.current
        
        view.scrollEnabled = true // 사용자가 스크롤을 할 수 있는지
        view.scrollDirection = .horizontal // 사용자 스크롤 방향
        
        view.appearance.borderRadius = 0.5 //선택된 날짜, or 오늘날짜 원에서 사각형으로 변경
        
        view.appearance.borderDefaultColor = UIColor(.clear)
        view.appearance.borderSelectionColor = UIColor.black //선택된 날짜 컬러
        
        
        // MARK: 맨 위 "년도 월" 표기 설정
        view.appearance.headerTitleColor = .black
        view.appearance.headerTitleFont = .mainFont(size: 20)
        //view.appearance.headerDateFormat = "yyyy년 MM월" // 날짜 디스플레이 양식
        
        // MARK: 요일 관련
        view.appearance.weekdayFont = .mainFont(size: 17) // 요일 폰트
        view.appearance.weekdayTextColor = UIColor.black // 요일 색
        //view.firstWeekday = 2 // 월요일부터 시작
        
        // MARK: 날짜별 설정
        view.appearance.todaySelectionColor = UIColor.white //오늘날짜 선택시 색상
        view.appearance.titleTodayColor = UIColor.black // 오늘 날짜 글자 색
        view.appearance.todayColor = UIColor.black // 오늘 요일 배경 색
        
        
        view.appearance.selectionColor = UIColor.red //선택 일자 색
        view.appearance.titleSelectionColor = UIColor.white // 선택한 날짜 글자색
        
        view.appearance.titlePlaceholderColor = .gray // 지난달 혹은 이후 달에 있는 날짜들 색상
        
        view.appearance.titleFont = .mainFont(size: 17)
        view.appearance.titleWeekendColor = UIColor.red// 주말 요일 색
        
        view.appearance.titlePlaceholderColor = UIColor(.white.opacity(0.4)) // 달에 유효하지 않은 날짜의 색 지정
        
        view.appearance.eventSelectionColor = .orange // 이벤트 표시가 있는 날짜를 선택시 색상
        view.appearance.eventDefaultColor = .blue // 일반 표시 색상
        
        view.headerHeight = 0
        //view.today = nil
        
        
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("ReloadCalendar"), object: nil, queue: .main) { _ in
            view.reloadData()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("goToToday"), object: nil, queue: .main) { _ in
            view.select(Date())
        }
        
        return view
    }
    
    func updateUIView(_ uiView: FSCalendar, context: Context) {
        uiView.setCurrentPage(pageCurrent, animated: true)
    }
    
    func makeCoordinator() -> CalendarCoordinator {
        CalendarCoordinator(calendar: self) {
            action()
        }
    }
    
    class CalendarCoordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        var parent: CustomCalendarView
        var action: () -> ()
        
        init(calendar: CustomCalendarView, action: @escaping () -> ()) {
            print("Init 호출")
            self.parent = calendar
            self.action = action
        }
        
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            print("선택한 날짜: \(date)")
            DispatchQueue.main.async {
                self.parent.selectedDate = date
            }
            
            action()
        }
        
        func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.timeZone = TimeZone(abbreviation: "UTC")
            
            guard let dateOnly = calendar.date(from: components) else {
                return nil
            }
            
            let allDate = self.parent.getAllTodoDateUseCase.execute()
            
            if allDate.contains(dateOnly) {
                return ""
            } else {
                return nil
            }
        }
        
        // MARK: Todo. 특정 날짜에 이모지 띄우기
        func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
            guard let cell = calendar.dequeueReusableCell(withIdentifier: CalendarCell.description(), for: date, at: position) as? CalendarCell else { return FSCalendarCell() }
            
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.timeZone = TimeZone(abbreviation: "UTC")
            
            guard let dateOnly = calendar.date(from: components) else {
                return FSCalendarCell()
            }
            
            let allDate = self.parent.getAllTodoDateUseCase.execute()
            
            if allDate.contains(dateOnly) {
                cell.backImageView.image = UIImage(named: "Coin")
            } else {
                cell.backImageView.image = nil
            }
            
            return cell
        }
        
        func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
            DispatchQueue.main.async {
                self.parent.pageCurrent = calendar.currentPage
            }
        }
    }
    
    
}

private extension String {
    func convertFormat() -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyyMMdd"
        
        // Step 2: Convert the input string to a Date object
        if let date = inputFormatter.date(from: self) {
            
            // Step 3: Set up another DateFormatter for the output format
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy-MM-dd"
            
            // Step 4: Convert the Date object to the desired output format
            let formattedDate = outputFormatter.string(from: date)
            
            print(formattedDate)  // Output: 2024-09-30
            
            return formattedDate
        } else {
            print("Invalid date string")
            
            return ""
        }
    }
}

private extension Date {
    func removeTime() -> Date {
        // Calendar를 사용하여 년월일 비교
        var calendar = Calendar.current
        guard let timeZone = TimeZone(secondsFromGMT: 0) else { return Date() }
        calendar.timeZone = timeZone  // UTC로 설정
        
        // 선택 날짜의 년, 월, 일 컴포넌트 추출
        let currentComponents = calendar.dateComponents([.year, .month, .day], from: self)
        
        // 4. Realm에서 년, 월, 일이 같은 데이터 쿼리
        // 최소 시간은 자정(해당 날짜의 시작)
        let startOfDay = calendar.date(from: currentComponents)!
        
        // 자정부터 하루의 마지막 시간까지 (해당 날짜의 끝)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // 5. 입력된 Date가 해당 범위에 포함되는지 확인
        if self >= startOfDay && self < endOfDay {
            return self // 포함된다면 해당 Date 리턴
        } else {
            return Date()
        }
    }
    
    func convertLocal() -> Date {
        let formatter = DateFormatter()
        
        // Set the date format and UTC timezone for the input
        formatter.timeZone = TimeZone(abbreviation: "UTC") // Input is in UTC
        
        // Convert the date to a string in UTC format
        let dateString = formatter.string(from: self)
        
        // Now set the formatter to the system's local timezone
        formatter.timeZone = TimeZone.current  // Local device timezone
        
        // Convert the date string back to a Date object in the local timezone
        return formatter.date(from: dateString) ?? Date()
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
