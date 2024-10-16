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
    
    func stringToUTCDate() -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale.current // POSIX 로케일 설정
        formatter.timeZone = TimeZone(abbreviation: "UTC")   // UTC 타임존 설정
        
        // 시도할 여러 가지 포맷
        let possibleFormats = [
            "MMM dd yyyy",         // "Oct 16 2024" 형식
            "yyyy년 MM월 dd일"     // "2024년 10월 16일" 형식
        ]
        
        // 가능한 포맷을 순회하며 날짜 변환 시도
        for format in possibleFormats {
            formatter.dateFormat = format
            if let date = formatter.date(from: self) {
                return date // 변환 성공 시 반환
            }
        }
        
        // 변환에 실패하면 nil 반환
        return Date()
    }
    
}
