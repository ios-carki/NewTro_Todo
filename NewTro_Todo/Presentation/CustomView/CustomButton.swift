//
//  CustomButton.swift
//  NewTro_Todo
//
//  Created by Carki on 2023/05/20.
//

import SwiftUI

struct CustomButton: View {
    
    var disabled : Binding<Bool>?
    var title: String?
    var backgroundColor: Color?
    var borderColor: Color?
    var textColor: Color?
    
    
    var body: some View {
        VStack{
            Text(title ?? "").font(.custom("Galmuri11-Condensed", size: 18))
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 54)
            .opacity(disabled?.wrappedValue ?? false ? 0.5 : 1)
            .background(
                (disabled?.wrappedValue == true) ? Color.gray : backgroundColor
            )
            .foregroundColor((disabled?.wrappedValue == true) ? .white : textColor)
            .cornerRadius(5.0)
            .overlay(RoundedRectangle(cornerRadius: 5.0)
                .stroke(
                    disabled?.wrappedValue ?? false ? .gray : borderColor ?? .white
                ).frame(height:55)
            )
            .font(.custom("Galmuri11-Condensed", size: 18))
            .contentShape(Rectangle())
        }
    }
}
extension CustomButton{
    func setDisabled(disabled: Binding<Bool>?) -> Self {
        var copy = self
        copy.disabled = disabled
        return copy
    }
    
    func setTitle(title: String?) -> Self {
        var copy = self
        copy.title = title
        return copy
    }
    
    func setType(type: ButtonType?) -> Self {
        var copy = self
        if type == .normal {
            copy.backgroundColor = Color(UIColor.mainBackGroundColor)
            copy.borderColor = Color(UIColor.mainBackGroundColor)
            copy.textColor = .white
        }
        
        if type == .clear {
            copy.backgroundColor = .clear
            copy.borderColor = .white
            copy.textColor = .white
        }
        return copy
    }
}

struct CustomButton_Previews: PreviewProvider {
    static var previews: some View {
        CustomButton()
            .setType(type: .normal)
            .setTitle(title: "Custom Button")
    }
}
