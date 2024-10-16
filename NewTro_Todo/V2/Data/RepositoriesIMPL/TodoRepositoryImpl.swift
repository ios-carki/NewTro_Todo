//
//  TodoRepositoryImpl.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/15/24.
//

import Foundation

final class TodoRepositoryImpl: TodoRepository {
    let dataBase: LocalTodoDataSource
    
    init(db: LocalTodoDataSource) {
        self.dataBase = db
    }
    
    func getPickedDateTodoData(pickedDate: Date) -> [TodoDomain] {
        self.dataBase.getPickedDateTodoData(pickedDate: pickedDate)
    }
    
    func getAllTodoDate() -> [Date] {
        self.dataBase.getAllTodoDate()
    }
}
