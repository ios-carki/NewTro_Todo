//
//  SelectCalendarMonthViewModel.swift
//  NewTro_Todo
//
//  Created by OWEN on 11/14/24.
//

import Foundation

final class SelectCalendarMonthViewModel: ObservableObject {
    
    let minYear = Date().year() - 10
    let maxYear = Date().year() + 10
    let monthData: [String] = Calendar.current.shortMonthSymbols

    func selectYearWithMonth(month: String, _ date: Date) -> Date {
        let selectedYear = date.year()
        let minYear = Date().year() - 10
        let maxYear = Date().year() + 10
        
        var dateComponent = DateComponents()
        dateComponent.day = 1
        dateComponent.month = monthData.firstIndex(of: month)! + 1
        dateComponent.year = max(minYear, min(maxYear, selectedYear))
        dateComponent.hour = 0
        dateComponent.minute = 0
        dateComponent.second = 0
        dateComponent.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        if let date = Calendar.current.date(from: dateComponent) {
            return date
        } else {
            print("날짜 변환 실패")
            return Date()
        }
    }
    
    func limitPastYear(_ date: Date) -> Date {
        print("이전 년도")
        var returnDate = date
        // 최대 10년 전으로 제한하기 위해 기준 날짜 설정
        let tenYearsAgo = Calendar.current.date(byAdding: .year, value: -10, to: Date())!

        // 현재 선택된 날짜에서 1년 빼기
        let newDate = Calendar.current.date(byAdding: .year, value: -1, to: date)!

        // 새로 계산된 날짜가 10년 전보다 이후인지 확인
        if newDate >= tenYearsAgo {
            returnDate = newDate
        } else {
            returnDate = tenYearsAgo
        }
        
        return returnDate
    }
    
    func limitFutureYear(_ date: Date) -> Date {
        print("다음 년도")
        var returnDate = date
        // 최대 10년 전으로 제한하기 위해 기준 날짜 설정
        let tenYearsAfter = Calendar.current.date(byAdding: .year, value: +10, to: Date())!

        // 현재 선택된 날짜에서 1년 빼기
        let newDate = Calendar.current.date(byAdding: .year, value: +1, to: date)!

        // 새로 계산된 날짜가 10년 전보다 이후인지 확인
        if newDate <= tenYearsAfter {
            returnDate = newDate
        } else {
            returnDate = tenYearsAfter
        }
        
        return returnDate
    }
}
