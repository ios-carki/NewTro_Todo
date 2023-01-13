//
//  DateFormat+Extension.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/15.
//

import Foundation
import UIKit

extension UILabel {
    func realmDateFormat() -> String {
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        
        let convertDate = dateFormatter.string(from: nowDate)
        return convertDate
    }
}

extension DateFormatter {
    
    static func dateToString(date: Date) -> String {
        let format = DateFormatter()
        format.locale = Locale.current
        format.timeZone = TimeZone.current
        format.dateFormat = "yyyy년 MM월 dd일"
        let result = format.string(from: date)
        return result
    }
    
}
