//
//  Color+Extension.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/06.
//

import SwiftUI
import UIKit

extension UIColor {
    //    137 215 237
    static let cellLabelBackGroundColor = UIColor(red: 122/255, green: 86/255, blue: 65/255, alpha: 1.0)
    static let cellBackGroundColor = UIColor(red: 78/255, green: 201/255, blue: 234/255, alpha: 1.0)
    static let pageViewBackGroundColor = UIColor(red: 137/255, green: 215/255, blue: 237/255, alpha: 1.0)
    static let mainBackGroundColor = UIColor(red: 109/255, green: 218/255, blue: 242/255, alpha: 1.0)
    static let mainBackGroundColorWithOpacity = UIColor(red: 73/255, green: 159/255, blue: 200/255, alpha: 1.0)
    static let bottomViewBackGroundColor = UIColor(red: 157/255, green: 148/255, blue: 148/255, alpha: 1.0)
    static let coinCountLabelColor = UIColor(red: 255/255, green: 231/255, blue: 114/255, alpha: 1.0)
//    static let calendarDayColor = UIColor(red: 89/255, green: 6/255, blue: 150/255, alpha: 1.0)
    static let calendarWeekendColor = UIColor(red: 199/255, green: 10/255, blue: 128/255, alpha: 1.0)
    static let calendarWeekdayColor = UIColor(red: 61/255, green: 123/255, blue: 53/255, alpha: 1.0)
    
}

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
    
    static let placeHolderC = Color(hex: "#929292")
    static let mainBackGroundC = Color(hex: "#6ddaf2")
    static let textFieldC = Color(hex: "#4ec8ea")
}
