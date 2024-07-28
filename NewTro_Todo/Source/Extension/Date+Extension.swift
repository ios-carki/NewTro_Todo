//
//  Date+Extension.swift
//  NewTro_Todo
//
//  Created by Carki on 2023/05/28.
//

import Foundation

extension Date {
    /// Returns the amount of days from another date
    func days() -> Int {
        return Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours() -> Int {
        return Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes() -> Int {
        return Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds() -> Int {
        return Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
    }
    func dateToString() -> String {
        let components = Calendar(identifier: .gregorian).dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second], from: self)
        let year = components.year
        let mounth = components.month
        let day = components.day
        let weekday = components.weekday
//        return "\(day ?? 0)/\(mounth ?? 0)/\(year ?? 0)"
        return "\(year ?? 0)년 \(mounth ?? 0)월 \(day ?? 0)일 \(weekday ?? 0)요일"
    }
}
