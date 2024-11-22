//
//  MainV2ViewModel.swift
//  NewTro_Todo
//
//  Created by OWEN on 11/18/24.
//

import Foundation

struct TestTodo: Hashable, Identifiable {
    let id: String = UUID().uuidString
    var text: String
}

final class MainV2ViewModel: ObservableObject {
    @Published var data: [TestTodo] = []
}
