//
//  TodoView.swift
//  NewTro_Todo
//
//  Created by OWEN on 11/18/24.
//

import SwiftUI

struct TodoView: View {
    var todoText: Binding<String>
    
    var body: some View {
        ZStack {
            Color.white
            CustomTextView(text: todoText)
        }
    }
}

#Preview {
    TodoView(todoText: .constant(""))
}
