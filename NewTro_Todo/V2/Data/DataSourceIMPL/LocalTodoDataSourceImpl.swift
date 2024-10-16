//
//  LocalTodoDataSourceImpl.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/15/24.
//

import Foundation

import RealmSwift

final class LocalTodoDataSourceImpl: LocalTodoDataSource {
    func getPickedDateTodoData(pickedDate: Date) -> [TodoDomain] {
        let realm = try! Realm()
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current//Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current//TimeZone(abbreviation: "KST")
        formatter.dateFormat = "yyyy년 MM월 dd일"
        
        let stringDate = formatter.string(from: pickedDate)
        
        return realm.objects(Todo.self).filter("stringDate == %@", stringDate).map{ $0.toTodoDomain() }
        
//        let formatter = DateFormatter()
////        formatter.locale = Locale.current//Locale(identifier: "ko_KR")
////        formatter.timeZone = TimeZone.current//TimeZone(abbreviation: "KST")
////        formatter.dateFormat = "yyyy년 MM월 dd일"
//        // Calendar를 사용하여 주어진 Date에서 년, 월, 일만 추출
//            let calendar = Calendar.current
//            let startOfDay = calendar.startOfDay(for: pickedDate) // 날짜의 00:00:00
//        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] } // 다음 날의 00:00:00
//        return realm.objects(Todo.self).filter("stringDate >= %@ AND stringDate < %@", startOfDay, endOfDay).map{ $0.toTodoDomain() }
    }
}
