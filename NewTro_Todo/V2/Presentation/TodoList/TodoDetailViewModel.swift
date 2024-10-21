//
//  TodoDetailViewModel.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/21/24.
//

import Foundation

import Factory

final class TodoDetailViewModel: ObservableObject {
    @Injected(\.deleteTodoUseCase) private var deleteTodoUseCase
    let todo: TodoDomain
    
    init(todo: TodoDomain) {
        self.todo = todo
    }
    
    func deleteTodo() {
        self.deleteTodoUseCase.execute(id: todo.id!)
    }
}
