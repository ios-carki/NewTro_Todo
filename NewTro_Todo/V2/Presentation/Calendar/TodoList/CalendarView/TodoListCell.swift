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
        HStack(spacing: 8) {
            Circle()
                .foregroundColor(NewtroColor.white)
                .frame(width: 15, height: 15)
                .overlay(
                    Circle()
                        .foregroundColor(data.isFinishedColor)
                        .frame(width: 10, height: 10)
                )
            VStack(spacing: 8) {
                if data.todo == "" {
                    Text("calendar_no_todo_text".localized())
                        .font(.galCondensed15())
                        .foregroundColor(NewtroColor.gray200)
                } else {
                    Text(data.todo)
                        .font(.galCondensed15())
                        .foregroundColor(NewtroColor.black)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
//                if let todoText = data.todo {
//                    if todoText == "" {
//                        Text("calendar_no_todo_text".localized())
//                            .font(.galCondensed15())
//                            .foregroundColor(NewtroColor.gray200)
//                    } else {
//                        Text(todoText)
//                            .font(.galCondensed15())
//                            .foregroundColor(NewtroColor.black)
//                            .lineLimit(1)
//                            .truncationMode(.tail)
//                    }
//                } else {
//                    Text("calendar_no_todo_text".localized())
//                        .font(.galCondensed15())
//                        .foregroundColor(NewtroColor.gray200)
//                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Image(systemName: "chevron.right")
                .foregroundColor(NewtroColor.black)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(NewtroColor.mainBackgroundColor)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 15, x: 0.0, y: 0.0)
        .onTapGesture {
            action()
        }
    }
}

#Preview {
    ZStack {
        NewtroColor.mainBackgroundColor.ignoresSafeArea()
        TodoListCell(
            data: TodoDomain(
                id: "",
                todo: "afdsiasdfasdfasdfasdfasdfasdfasdfasdfjasdfijonasdfioasdfojasdfafdsiasdfasdfasdfasdfasdfasdfasdfasdfjasdfijonasdfioasdfojasdf",
                favorite: "",
                importance: "",
                regDate: Date(),
                selectedDate: Date(),
                isFinishedText: "",
                isFinishedColor: .red
            )
        ) {
            
        }
    }
}
