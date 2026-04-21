//
//  Font+Extension.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/08.
//

import SwiftUI
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

extension Font {
    enum Galmuri {
        case galmuriBold
        case galmuriCondensed
        
        var value: String {
            switch self {
            case .galmuriBold:
                return "Galmuri11-Bold"
            case .galmuriCondensed:
                return "Galmuri11-Condensed"
            }
        }
    }
    
    //MARK: Bold
    static func galBold40() -> Font {
        return .custom(Galmuri.galmuriBold.value, size: 40)
    }
    static func galBold20() -> Font {
        return .custom(Galmuri.galmuriBold.value, size: 20)
    }
    static func galBold17() -> Font {
        return .custom(Galmuri.galmuriBold.value, size: 17)
    }
    static func galBold16() -> Font {
        return .custom(Galmuri.galmuriBold.value, size: 16)
    }

    //MARK: Condensed
    static func mainFont16() -> Font {
        return .custom(Galmuri.galmuriCondensed.value, size: 16)
    }
    static func galCondensed20() -> Font {
        return .custom(Galmuri.galmuriCondensed.value, size: 20)
    }
    static func galCondensed18() -> Font {
        return .custom(Galmuri.galmuriCondensed.value, size: 18)
    }
    static func galCondensed16() -> Font {
        return .custom(Galmuri.galmuriCondensed.value, size: 16)
    }
}
