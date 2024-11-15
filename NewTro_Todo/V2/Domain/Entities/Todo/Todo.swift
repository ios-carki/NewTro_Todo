//
//  Todo.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/15/24.
//

import SwiftUI

struct TodoDomain {
    let id: String?
    let todo: String?
    let favorite: String
    let importance: String
    let regDate: Date
    let selectedDate: Date
    let isFinishedText: String
    let isFinishedColor: Color
}
