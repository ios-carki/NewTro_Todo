//
//  TodoScheme.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/15.
//

import Foundation

import RealmSwift

class Todo: Object {
    
    @Persisted var todo: String?
    @Persisted var favorite: Bool
    @Persisted var importance: Int
    @Persisted var regDate = Date()
    @Persisted var stringDate: String
    @Persisted var isFinished: Bool
    
    @Persisted(primaryKey: true) var objectID: ObjectId
    
    convenience init(todo: String?, favorite: Bool, importance: Int, regDate: Date, stringDate: String, isFinished: Bool) {
        self.init()
        self.todo = todo
        self.favorite = favorite
        self.importance = importance
        self.regDate = regDate
        self.stringDate = stringDate
        self.isFinished = isFinished
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
