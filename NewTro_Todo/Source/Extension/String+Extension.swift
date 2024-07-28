//
//  String+Extension.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/10/02.
//

import Foundation

extension String {
    
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
    
    func localized(with argument: CVarArg = [], comment: String = "") -> String {
        return String(format: self.localized(comment: comment), argument)
    }
    
    func dateToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 EEE"
        
        let convertDate = dateFormatter.date(from: self)
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        dateFormatter.locale = Locale.current
        let convertstr = myDateFormatter.string(from: convertDate ?? Date())
        
        return convertstr
    }
}
