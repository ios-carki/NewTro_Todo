//
//  TodoListViewModel.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/15/24.
//

import Foundation

import Factory

final class TodoListViewModel: ObservableObject {
    @Injected(\.todoListUseCase) private var todoListUseCase
    @Published var todoData: [TodoDomain] = []
    
    //Calendar
    @Published var selectedDate: Date = Date() { didSet { getAllTodoData() } }
    @Published var currentMonth: Date = Date()
    
    func getAllTodoData() {
        self.todoData = self.todoListUseCase.execute(pickedDate: selectedDate)
    }
}
