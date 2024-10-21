//
//  TodoListCell.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/15/24.
//

import SwiftUI

struct TodoListCell: View {
    let data: TodoDomain
    
    let action: () -> ()
    
    var body: some View {
        VStack {
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Circle()
                        .foregroundColor(NewtroColor.white)
                        .frame(width: 15, height: 15)
                        .overlay(
                            Circle()
                                .foregroundColor(data.isFinished ? NewtroColor.success : NewtroColor.fail)
                                .frame(width: 10, height: 10)
                        )
                    VStack(spacing: 4) {
                        if let todoText = data.todo {
                            Text(todoText)
                                .foregroundColor(NewtroColor.black)
                        } else {
                            Text("투두를 작성하지 않았습니다.")
                                .foregroundColor(NewtroColor.gray200)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .cornerRadius(12)
        .onTapGesture {
            action()
        }
    }
}

#Preview {
    TodoListCell(
        data: TodoDomain(
            id: "",
            todo: "afdsiasdfasdfasdfasdfasdfasdfasdfasdfjasdfijonasdfioasdfojasdfafdsiasdfasdfasdfasdfasdfasdfasdfasdfjasdfijonasdfioasdfojasdf",
            favorite: false,
            importance: 0,
            regDate: Date(),
            selectedDate: Date(),
            isFinished: true
        )
    ) {
        
    }
}
