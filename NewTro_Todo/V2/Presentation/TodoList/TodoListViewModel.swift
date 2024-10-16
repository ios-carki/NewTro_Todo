//
//  TodoListViewModel.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/15/24.
//

import Foundation

import Factory

final class TodoListViewModel: ObservableObject {
    @Injected(\.getPickedDateTodoUseCase) private var getPickedDateTodoUseCase
    @Published var todoData: [TodoDomain] = []
    
    //Calendar
    @Published var selectedDate: Date = Date() { didSet { getPickedDateTodoData() } }
    @Published var currentMonth: Date = Date()
    
    func getPickedDateTodoData() {
        self.todoData = self.getPickedDateTodoUseCase.execute(pickedDate: selectedDate)
    }
}
