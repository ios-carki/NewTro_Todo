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
        
        // 선택한 날짜의 year, month, day 추출
        let calendar = Calendar.current
        let selectedYear = calendar.component(.year, from: pickedDate)
        let selectedMonth = calendar.component(.month, from: pickedDate)
        let selectedDay = calendar.component(.day, from: pickedDate)
        
        // Realm 쿼리로 해당 년/월/일이 같은 데이터를 필터링
        let results = realm.objects(Todo.self).filter { todo in
            let todoYear = calendar.component(.year, from: todo.regDate)
            let todoMonth = calendar.component(.month, from: todo.regDate)
            let todoDay = calendar.component(.day, from: todo.regDate)
            
            return todoYear == selectedYear && todoMonth == selectedMonth && todoDay == selectedDay
        }
        
        return results.map{ $0.toTodoDomain() }
    }
}
