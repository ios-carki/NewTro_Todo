//
//  DIContainer.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/15/24.
//

import Foundation

import Factory

//MARK: LocalDB
extension Container {
    var localTodoDataSource: Factory<LocalTodoDataSource> {
        Factory(self) { LocalTodoDataSourceImpl() }
    }
}

//MARK: Repository
extension Container {
    var TodoRepository: Factory<TodoRepository> {
        Factory(self) { TodoRepositoryImpl(db: self.localTodoDataSource()) }
    }
}

//MARK: UseCase
extension Container {
    //MARK: Todo
    var todoListUseCase: Factory<TodoListUseCase> {
        Factory(self) { TodoListUseCase(repository: self.TodoRepository()) }
    }
}
