//
//  TodoDetailView.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/21/24.
//

import SwiftUI

struct TodoDetailView: View {
    weak var navigation: UINavigationController?
    @StateObject var viewModel: TodoDetailViewModel
    
    var body: some View {
        ZStack {
            NewtroColor.mainBackgroundColor.ignoresSafeArea()
            
            VStack(spacing: 30) {
                if let todoText = viewModel.todo.todo {
                    todoView(text: todoText)
                        .padding(.top, 30)
                }
                
                VStack(spacing: 16) {
                    informationView(text: "중요도", contents: "\(viewModel.todo.importance)")
                    informationView(text: "즐겨찾기", contents: "\(viewModel.todo.favorite)")
                    informationView(text: "등록날짜", contents: "\(viewModel.todo.regDate.calendarTodayDateFormat())")
                    informationView(text: "완료 / 미완료", contents: viewModel.todo.isFinished ? "완료" : "미완료")
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.deleteTodo()
                    self.navigation?.popViewController(animated: true)
                }, label: {
                    Text("DeleteButton_SetTitle".localized())
                        .font(.galCondensed20())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                })
                .background(NewtroColor.fail)
                .cornerRadius(8)
                .frame(minHeight: 44)
                .padding(.horizontal, 16)
            }
            .padding(.horizontal, 16)
        }
    }
    
    @ViewBuilder
    private func todoView(text: String) -> some View {
        HStack {
            Text("\(text)")
                .font(.galCondensed16())
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(NewtroColor.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
        .background(NewtroColor.gray300)
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private func informationView(text: String, contents: String) -> some View {
        HStack {
            Text("[ \(text) ]")
                .font(.galCondensed20())
                .lineLimit(1)
                .foregroundColor(NewtroColor.white)
            Spacer()
            Text("\(contents)")
                .font(.galCondensed16())
                .lineLimit(1)
                .foregroundColor(NewtroColor.retroGray)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    TodoDetailView(
        viewModel: TodoDetailViewModel(todo: TodoDomain(id: "", todo: "Todo Data 변함Todo Data 변함Todo Data 변함Todo Data 변함Todo Data 변함Todo Data 변함Todo Data 변함", favorite: false, importance: 0, regDate: Date(), selectedDate: Date(), isFinished: false)))
}
