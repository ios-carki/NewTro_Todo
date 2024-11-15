//
//  TodoScheme.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/15.
//

import Foundation

import RealmSwift

class Todo: Object, ObjectKeyIdentifiable {
    
    @Persisted var todo: String?
    @Persisted var favorite: Bool
    @Persisted var importance: Int
    @Persisted var regDate = Date()
    @Persisted var stringDate: String
    @Persisted var isFinished: Bool
    @Persisted var selectedDate: Date
    
    @Persisted(primaryKey: true) var objectID: ObjectId
    
    convenience init(todo: String?, favorite: Bool, importance: Int, regDate: Date, stringDate: String, selectedDate: Date, isFinished: Bool) {
        self.init()
        self.todo = todo
        self.favorite = favorite
        self.importance = importance
        self.regDate = regDate
        self.stringDate = stringDate
        self.isFinished = isFinished
        self.selectedDate = selectedDate
    }
}

extension Todo {
    func toTodoDomain() -> TodoDomain {
        let importanceText = Info.Importance(id: self.importance)?.text ?? "Unknown"
        let favoriteText = Info.Favorite(value: self.favorite).text
        let completedText = Info.Completed(value: self.isFinished).text
        let completedColor = Info.Completed(value: self.isFinished).color
        
        return TodoDomain(
            id: self.objectID.stringValue,
            todo: self.todo,
            favorite: favoriteText,
            importance: importanceText,
            regDate: self.regDate,
            selectedDate: self.selectedDate,
            isFinishedText: completedText,
            isFinishedColor: completedColor
        )
    }
}

class QuickNote: Object {
    
    @Persisted var note: String?
    @Persisted var regDate = Date()
    @Persisted var stringToRegDate: String
    @Persisted var isWrited: Bool
    
    @Persisted(primaryKey: true) var objectID: ObjectId
    
    convenience init(note: String?, regDate: Date, stringToRegDate: String, isWrited: Bool) {
        self.init()
        self.note = note
        self.regDate = regDate
        self.stringToRegDate = stringToRegDate
        self.isWrited = isWrited
    }
}

