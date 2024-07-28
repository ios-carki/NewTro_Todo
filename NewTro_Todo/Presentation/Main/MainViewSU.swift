//
//  MainViewSU.swift
//  NewTro_Todo
//
//  Created by Carki on 2023/05/20.
//

import SwiftUI

struct MainViewSU: View {
    var body: some View {
        ZStack {
            Color(UIColor.mainBackGroundColor).ignoresSafeArea()
            
            VStack {
                HStack(spacing: 4) {
                    Image("Coin")
                        .resizable()
                        .frame(width: 50, height: 50)
                    
                    Text("20222222")
                        .foregroundColor(Color(UIColor.coinCountLabelColor))
                        .font(.galBold20())
                    
                    Spacer()
                    
                    HStack(spacing: -20) {
                        Image("Heart")
                            .resizable()
                            .frame(width: 50, height: 50)
                        
                        Image("Heart")
                            .resizable()
                            .frame(width: 50, height: 50)
                        
                        Image("Heart")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                }
                .padding(.horizontal, 12)
                
                HStack(alignment: .center, spacing: 14) {
                    Image("YesterDayBtn")
                        .resizable()
                        .frame(width: 50, height: 50)
                    
                    Text("오늘날짜")
                        .foregroundColor(.white)
                        .font(.galBold20())
                    
                    Image("TomorrowBtn")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                
                Color.white
                    .frame(height: 1)
                    
                HStack(alignment: .center, spacing: 8) {
                    Image("TodoBtn")
                        .resizable()
                        .frame(width: 50, height: 50)
                    
                    Image("NoteBtn")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                
                VStack(spacing: 14) {
                    ForEach(0..<4, id: \.self) { index in
                        TodoCellView(todoText: .constant("adsffsda"))
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
                
                Image("MainBackGround")
                    .resizable()
                    .frame(height: 90)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 0)
                    .padding(.bottom, -40)
            }
        }
    }
}

struct MainViewSU_Previews: PreviewProvider {
    static var previews: some View {
        MainViewSU()
    }
}
