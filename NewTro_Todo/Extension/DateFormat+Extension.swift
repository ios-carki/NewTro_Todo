//
//  DateFormat+Extension.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/15.
//

import Foundation

class DateFormat {
    
    func realmDateFormat() {
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 dd일 hh시 mm분"
        
        let convertDate = dateFormatter.string(from: nowDate)
    }
}
