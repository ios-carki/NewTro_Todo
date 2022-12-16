//
//  Font+Extension.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/08.
//

import Foundation
import UIKit

extension UIFont {
    
    static func mainFont(size: Double) -> UIFont {
        let galmuri = UIFont(name: "Galmuri11-Condensed", size: size)
        return galmuri!
    }
    
    static func boldFont(size: Double) -> UIFont {
        let galmuriBold = UIFont(name: "Galmuri11-Bold", size: size)
        return galmuriBold!
    }
}
