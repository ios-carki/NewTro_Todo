//
//  TodoDetailPopupView.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/21/24.
//

import SwiftUI

struct TodoDetailPopupView: View {
    weak var navigation: UINavigationController?
    let todo: TodoDomain
    
    let dismissAction: () -> ()
    let deleteActon: () -> ()
    
    var body: some View {
        ZStack {
            NewtroColor.black.opacity(0.4).ignoresSafeArea()
                .onTapGesture {
                    dismissAction()
                }
            
            VStack(spacing: 16) {
                Text("세부 정보")
                    .padding(.vertical, 4)
                    .foregroundColor(NewtroColor.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(NewtroColor.retroBlue)
                
                todoView(text: todo.todo)
                
                VStack(spacing: 16) {
                    informationView(text: "중요도", contents: "\(todo.importance)")
                    informationView(text: "즐겨찾기", contents: "\(todo.favorite)")
                    informationView(text: "등록날짜", contents: "\(todo.regDate.calendarTodayDateFormat())")
                    informationView(text: "완료 / 미완료", contents: todo.isFinishedText)
                    
                    VStack(spacing: 4) {
                        HStack {
                            Spacer()
                            Text("DeleteButton_SetTitle".localized())
                                .font(.galCondensed20())
                                .padding(.vertical, 8)
                                .foregroundColor(.red)
                                .padding(.trailing, 16)
                                .onTapGesture(count: 2) {
                                    deleteActon()
                                }
                        }
                        HStack {
                            Spacer()
                            Text("*빠르게 두번 누르면 삭제됩니다.")
                                .font(.galCondensed12())
                                .foregroundColor(.red)
                                .padding(.trailing, 16)
                        }
                    }
                }
                
                Text("확인")
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(NewtroColor.retroBlue)
                    .foregroundColor(.white)
                    .onTapGesture {
                        dismissAction()
                    }
            }
            .background(NewtroColor.black)
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
        .background(NewtroColor.gray700)
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
    TodoDetailPopupView(
        todo: TodoDomain(
            id: "",
            todo: "밥먹기밥먹기밥먹기밥먹기밥먹기밥먹기밥먹기밥먹기밥먹기밥먹기밥먹기밥먹기",
            favorite: "",
            importance: "",
            regDate: Date(),
            selectedDate: Date(),
            isFinishedText: "",
            isFinishedColor: .red
        )) {
            
        } deleteActon: {
            
        }

}
