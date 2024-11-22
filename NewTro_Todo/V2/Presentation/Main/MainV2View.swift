//
//  MainV2View.swift
//  NewTro_Todo
//
//  Created by OWEN on 11/18/24.

//
import SwiftUI

struct MainV2View: View {
    weak var navigation: UINavigationController?
    @StateObject private var viewModel = MainV2ViewModel()
    
    init(navigation: UINavigationController?) {
        UITextView.appearance().textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    var body: some View {
        ZStack {
            NewtroColor.mainBackgroundColor.ignoresSafeArea()
            
            VStack(spacing: 12) {
                HStack(spacing: 18) {
                    Image("Coin")
                        .resizable()
                        .frame(width: 50, height: 50)
                    
                    Text("111824")
                        .font(.galBold20())
                        .foregroundColor(Color(uiColor: .coinCountLabelColor))
                        .padding(.leading, -12)
                    
                    Spacer()
                    
                    Image("Heart")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding(.trailing, -20)
                    
                    Image("Heart")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding(.trailing, -20)
                    
                    Image("Heart")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                
                Button(action: {
                    viewModel.data.append(TestTodo(text: ""))
                }, label: {
                    Text("추가")
                })
                
                ScrollView(showsIndicators: false) {
                    ForEach($viewModel.data, id: \.id) { todo in
                        TextEditor(text: todo.text)
                            .background(Color.white)
                            .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
                        //TodoView(todoText: $viewModel.todoText)
                    }
                }
            }
        }
    }
}

#Preview {
    MainV2View(navigation: UINavigationController())
}
