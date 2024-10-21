//
//  LocalTodoDataSource.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/15/24.
//

import Foundation

protocol LocalTodoDataSource {
    func getPickedDateTodoData(pickedDate: Date) -> [TodoDomain]
    func getAllTodoDate() -> [Date]
    func deleteTodo(id: String)
}
