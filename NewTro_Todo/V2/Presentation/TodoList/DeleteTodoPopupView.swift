//
//  DeleteTodoPopupView.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/22/24.
//

import SwiftUI

struct DeleteTodoPopupView: View {
    var mainTitleText: String
    var subTitleText: String?
    
    var deleteAction: () -> ()
    var dismissAction: () -> ()
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
                .onTapGesture {
                    dismissAction()
                }
            
            VStack(spacing: 16) {
                Text(mainTitleText)
                    .font(.galCondensed18())
                    .padding(.vertical, 4)
                    .foregroundColor(NewtroColor.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(NewtroColor.retroBlue)
                
                if let text = subTitleText {
                    Text(text)
                        .font(.galCondensed20())
                        .foregroundColor(NewtroColor.myWhite)
                        .frame(height: 100)
                }
                
                HStack(spacing: 0) {
                    Text("삭제")
                        .font(.galCondensed18())
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(NewtroColor.retroRed)
                        .foregroundColor(.white)
                        .onTapGesture {
                            deleteAction()
                        }
                    
                    Text("취소")
                        .font(.galCondensed18())
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(NewtroColor.retroGray)
                        .foregroundColor(.white)
                        .onTapGesture {
                            dismissAction()
                        }
                }
            }
            .background(NewtroColor.black)
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    DeleteTodoPopupView(mainTitleText: "삭제하기", subTitleText: "삭제 버튼을 누르면 삭제됩니다.") {
        
    } dismissAction: {
        
    }
}

/*
 HStack {
     CustomButton(title: "삭제", backgroundColor: NewtroColor.retroRed, borderColor: nil, textColor: NewtroColor.myWhite)
         .onTapGesture {
             buttonAction()
         }
     
     CustomButton(title: "취소", backgroundColor: NewtroColor.retroBlue, borderColor: nil, textColor: NewtroColor.myWhite)
         .onTapGesture {
             buttonAction()
         }
 }
 .padding(.top, 12)
 .padding(.bottom, -12)
 */
