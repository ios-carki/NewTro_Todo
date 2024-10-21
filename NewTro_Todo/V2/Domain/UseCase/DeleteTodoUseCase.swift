//
//  DeleteTodoUseCase.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/21/24.
//

import Foundation

final class DeleteTodoUseCase {
    let repository: TodoRepository
    
    init(repository: TodoRepository) {
        self.repository = repository
    }
    
    func execute(id: String) {
        self.repository.deleteTodo(id: id)
    }
}
