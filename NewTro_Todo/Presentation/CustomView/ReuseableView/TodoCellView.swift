//
//  TodoCellView.swift
//  NewTro_Todo
//
//  Created by Carki on 2023/05/27.
//

import SwiftUI

import CustomTextField

struct TodoCellView: View {
    
    var todoText: Binding<String>
    var clearButtonAction: (() -> ())?
    var moreButtonAction: (() -> ())?
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .foregroundColor(.black)
            .overlay(
                HStack(alignment: .center, spacing: 4, content: {
                    Image("ClearBtn")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            clearButtonAction?()
                        }
                        .padding(.horizontal, 8)
                    
                    EGTextField(text: todoText)
                        .setPlaceHolderText("할일을 입력해주세요")
                    
                    Image(systemName: "ellipsis")
                        .onTapGesture {
                            moreButtonAction?()
                        }
                        .padding(.horizontal, 12)
                })
                
            )
            .frame(height: 50)
    }
}

struct TodoCellView_Previews: PreviewProvider {
    static var previews: some View {
        TodoCellView(todoText: .constant(""))
    }
}
