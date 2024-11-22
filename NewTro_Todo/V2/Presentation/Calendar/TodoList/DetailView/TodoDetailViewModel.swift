//
//  TodoDetailViewModel.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/21/24.
//

import Foundation

import Factory

enum DetailViewMode {
    case read
    case edit
}

final class TodoDetailViewModel: ObservableObject {
    @Injected(\.deleteTodoUseCase) private var deleteTodoUseCase
    @Published var viewMode: DetailViewMode = .read
    @Published var todo: TodoDomain
    
    init(todo: TodoDomain) {
        self.todo = todo
    }
    
    func deleteTodo() {
        self.deleteTodoUseCase.execute(id: todo.id!)
    }
}
