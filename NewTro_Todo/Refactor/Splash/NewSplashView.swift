//
//  NewSplashView.swift
//  NewTro_Todo
//
//  Created by Carki on 2023/11/05.
//

import SwiftUI

struct NewSplashView: View {
    @State private var isSplash: Bool = false
    @State private var offsetX: CGFloat = UIScreen.main.bounds.width
    var body: some View {
        ZStack {
            Color(UIColor.mainBackGroundColor).ignoresSafeArea()
            
            VStack(spacing: 8) {
                HStack(spacing: 2) {
                    Text("N")
                    Text("e")
                    Text("w")
                    Text("T")
                    Text("r")
                    Text("o")
                }
                .font(.galBold40())
                .scaleEffect(isSplash ? 1 : 0)
                .animation(.linear(duration: 0.5), value: isSplash)
                
                HStack(spacing: 2) {
                    Text("T")
                    Text("o")
                    Text("D")
                    Text("o")
                }
                .font(.galBold40())
                .offset(x: offsetX)
            }
        }
        .onAppear {
            isSplash = true
            withAnimation(.spring(response: 1, dampingFraction: 0.7, blendDuration: 0.1)) {
                offsetX = 0
            }
        }
    }
}

struct NewSplashView_Previews: PreviewProvider {
    static var previews: some View {
        NewSplashView()
    }
}
