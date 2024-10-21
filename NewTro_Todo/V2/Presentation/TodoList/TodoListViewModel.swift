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
    @Injected(\.getAllTodoDateUseCase) private var getAllTodoDateUseCase
    @Published var allTodoDateData: [Date]  = []
    @Published var todoData: [TodoDomain] = [] {
        didSet {
            print("Todo Data 변함")
            self.reloadDateData()
        }
    }
    
    //Calendar
    @Published var selectedDate: Date = Date() { didSet { getPickedDateTodoData() } }
    @Published var currentMonth: Date = Date()
    
    init() {
        self.allTodoDateData = self.getAllTodoDateUseCase.execute()
    }
    
    func reloadDateData() {
        self.allTodoDateData = self.getAllTodoDateUseCase.execute()
    }
    
    func getPickedDateTodoData() {
        self.todoData = self.getPickedDateTodoUseCase.execute(pickedDate: selectedDate)
    }
}
