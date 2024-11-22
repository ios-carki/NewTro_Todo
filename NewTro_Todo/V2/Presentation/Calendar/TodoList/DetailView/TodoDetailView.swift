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
    
    init(navigation: UINavigationController?, viewModel: TodoDetailViewModel) {
        self.navigation = navigation
        self._viewModel = StateObject(wrappedValue: { TodoDetailViewModel(todo: viewModel.todo) }())
        
        UITextView.appearance().textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }
    
    var body: some View {
        ZStack {
            NewtroColor.mainBackgroundColor.ignoresSafeArea()
            
            VStack(spacing: 30) {
//                if let todoText = viewModel.todo.todo {
//                    todoView(text: todoText)
//                        .padding(.top, 30)
//                }
                todoView(text: viewModel.todo.todo)
                    .padding(.top, 30)
                
                VStack(spacing: 16) {
                    informationView(text: "detail_importance_text".localized(), contents: "\(viewModel.todo.importance)")
                    informationView(text: "detail_favorite_text".localized(), contents: "\(viewModel.todo.favorite)")
                    informationView(text: "detail_registered_date_text".localized(), contents: "\(viewModel.todo.regDate.calendarSelectedDateFormat())")
                    informationView(text: "detail_is_completed_text".localized(), contents: viewModel.todo.isFinishedText)
                }
                
                Spacer()
                
                switch viewModel.viewMode {
                case .read:
                    HStack(spacing: 12) {
                        button(text: "detail_delete_button_text".localized(), backgroundColor: NewtroColor.fail) {
                            let vc = UIHostingController(
                                rootView: DeleteTodoPopupView(mainTitleText: "popup_delete_title_text".localized(), subTitleText: "popup_delete_main_text".localized(), deleteAction: {
                                    viewModel.deleteTodo()
                                    self.navigation?.dismiss(animated: false)
                                    self.navigation?.popViewController(animated: true)
                                }, dismissAction: {
                                    self.navigation?.dismiss(animated: false)
                                })
                            )
                            
                            vc.view.backgroundColor = UIColor.clear
                            vc.modalPresentationStyle = .overCurrentContext
                            self.navigation?.present(vc, animated: false)
                        }
                        
                        button(text: "detail_edit_button_text".localized(), backgroundColor: NewtroColor.retroBlue) {
                            viewModel.viewMode = .edit
                        }
                    }
                case .edit:
                    button(text: "detail_edit_save_button_text".localized(), backgroundColor: NewtroColor.success) {
                        viewModel.viewMode = .read
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    @ViewBuilder
    private func button(text: String, backgroundColor: Color, action: @escaping () -> ()) -> some View {
        Button(action: {
            action()
        }, label: {
            Text(text)
                .font(.galCondensed20())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
        })
        .background(backgroundColor)
        .cornerRadius(8)
        .frame(minHeight: 44)
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private func todoView(text: String) -> some View {
        HStack {
            switch viewModel.viewMode {
            case .read:
                ScrollView(showsIndicators: false) {
                    Text("\(text)")
                        .font(.galCondensed16())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(NewtroColor.myBlack)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
            case .edit:
                CustomTextView(text: $viewModel.todo.todo)
                    .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
                    .padding(.vertical, 8)
            }
//            TextEditor(text: $viewModel.todo.todo)
//                .background(Color.clear)
//                .background(Color(uiColor: .cellBackGroundColor))
//                .cornerRadius(16)
//                .font(.galCondensed16())
//                .foregroundColor(NewtroColor.black)
//                .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
//            Text("\(text)")
//                .font(.galCondensed16())
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .foregroundColor(NewtroColor.white)/
//                .padding(.horizontal, 16)
//                .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
        .background(Color(uiColor: .cellBackGroundColor))
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
        navigation: UINavigationController(),
        viewModel: TodoDetailViewModel(
            todo: TodoDomain(
                id: "",
                todo: "Todo Data 변함Todo Data 변함Todo Data 변함Todo Data 변함Todo Data 변함Todo Data 변함Todo Data 변함",
                favorite: "",
                importance: "",
                regDate: Date(),
                selectedDate: Date(),
                isFinishedText: "",
                isFinishedColor: .red
            )
        )
    )
}
