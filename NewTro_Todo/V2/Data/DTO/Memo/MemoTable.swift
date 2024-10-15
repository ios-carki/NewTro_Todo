//
//  MemoTable.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/15/24.
//

import Foundation

import RealmSwift

class MemoTable: Object {
    
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

