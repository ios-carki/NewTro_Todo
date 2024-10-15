//
//  TodoListUseCase.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/15/24.
//

import Foundation

final class TodoListUseCase {
    let repository: TodoRepository
    
    init(repository: TodoRepository) {
        self.repository = repository
    }
    
    func execute(pickedDate: Date) -> [TodoDomain] {
        self.repository.getPickedDateTodoData(pickedDate: pickedDate)
    }
}
