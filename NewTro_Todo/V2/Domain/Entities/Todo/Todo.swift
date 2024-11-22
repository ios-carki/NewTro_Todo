//
//  Todo.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/15/24.
//

import SwiftUI

struct TodoDomain {
    let id: String?
    var todo: String
    var favorite: String
    var importance: String
    let regDate: Date
    let selectedDate: Date
    let isFinishedText: String
    let isFinishedColor: Color
}
