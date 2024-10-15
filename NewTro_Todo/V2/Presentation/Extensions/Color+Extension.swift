//
//  Color+Extension.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/15/24.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >>  8) & 0xFF) / 255.0
        let b = Double((rgb >>  0) & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
    
    init(r: Double, g: Double, b: Double) {
        self.init(
            red: r / 255.0,
            green: g / 255.0,
            blue: b / 255.0
        )
    }
}
