//
//  GetAllTodoDateUseCase.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/16/24.
//

import Foundation

final class GetAllTodoDateUseCase {
    let repository: TodoRepository
    
    init(repository: TodoRepository) {
        self.repository = repository
    }
    
    func execute() -> [Date] {
        self.repository.getAllTodoDate()
    }
}

