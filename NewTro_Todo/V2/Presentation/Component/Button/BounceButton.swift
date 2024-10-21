//
//  BounceButton.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/21/24.
//

import SwiftUI

struct BounceButton: ButtonStyle {
    var labelColor = NewtroColor.white
    var backgroundColor = NewtroColor.mainBackgroundColor
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(labelColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(RoundedRectangle(cornerRadius: 12).fill(backgroundColor))
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .shadow(color: .black.opacity(0.2), radius: 15, x: 0.0, y: 0.0)
    }
}
