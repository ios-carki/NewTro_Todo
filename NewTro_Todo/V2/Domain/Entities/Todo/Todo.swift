//
//  Todo.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/15/24.
//

import Foundation

struct TodoDomain {
    let id: String?
    let todo: String?
    let favorite: Bool
    let importance: Int
    let regDate: Date
    let selectedDate: Date
    let isFinished: Bool
}
