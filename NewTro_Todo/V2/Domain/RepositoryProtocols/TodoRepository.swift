//
//  TodoRepository.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/15/24.
//

import Foundation

protocol TodoRepository {
    func getPickedDateTodoData(pickedDate: Date) -> [TodoDomain]
    func getAllTodoDate() -> [Date]
}
