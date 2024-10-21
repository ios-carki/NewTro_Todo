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
        
        // 1. 현재 달력 객체
        let calendar = Calendar.current
        
        // 2. 선택된 날짜의 시작(자정)과 끝(23:59:59) 범위 생성
        var startOfDay = calendar.startOfDay(for: pickedDate)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1) else {
            return []
        }
        
        // 3. Realm 쿼리를 통해 해당 범위에 포함된 데이터가 있는지 확인
        return realm.objects(Todo.self)
            .filter("selectedDate >= %@ AND selectedDate <= %@", startOfDay, endOfDay)
            .map { $0.toTodoDomain() }
    }
    
    func getAllTodoDate() -> [Date] {
        let realm = try! Realm()
        
        return realm
            .objects(Todo.self)
            .map{ $0.toTodoDomain().selectedDate }
    }
}
