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
        
        // Calendar를 사용하여 년월일 비교
        var calendar = Calendar.current
        guard let timeZone = TimeZone(secondsFromGMT: 0) else { return [] }
        calendar.timeZone = timeZone  // UTC로 설정
        
        // 선택 날짜의 년, 월, 일 컴포넌트 추출
        let currentComponents = calendar.dateComponents([.year, .month, .day], from: pickedDate)

        // 4. Realm에서 년, 월, 일이 같은 데이터 쿼리
        // 최소 시간은 자정(해당 날짜의 시작)
        let startOfDay = calendar.date(from: currentComponents)!

        // 자정부터 하루의 마지막 시간까지 (해당 날짜의 끝)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        // 5. 해당 날짜 범위에 포함된 데이터 쿼리
        return realm
            .objects(Todo.self)
            .filter("selectedDate >= %@ AND selectedDate < %@", startOfDay, endOfDay)
            .map{ $0.toTodoDomain() }
    }
    
    func getAllTodoDate() -> [Date] {
        let realm = try! Realm()
        
        return realm
            .objects(Todo.self)
            .map{ $0.toTodoDomain().selectedDate }
    }
}
