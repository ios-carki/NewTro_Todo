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
                if let todoText = data.todo {
                    if todoText == "" {
                        Text("투두를 작성하지 않았습니다.")
                            .font(.galCondensed15())
                            .foregroundColor(NewtroColor.gray200)
                    } else {
                        Text(todoText)
                            .font(.galCondensed15())
                            .foregroundColor(NewtroColor.black)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                } else {
                    Text("투두를 작성하지 않았습니다.")
                        .font(.galCondensed15())
                        .foregroundColor(NewtroColor.gray200)
                }
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
