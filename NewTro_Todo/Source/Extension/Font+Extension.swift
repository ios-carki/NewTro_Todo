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
        UIFont(name: "Galmuri11-Condensed", size: size) ?? .systemFont(ofSize: size)
    }
    static func boldFont(size: Double) -> UIFont {
        UIFont(name: "Galmuri11-Bold", size: size) ?? .boldSystemFont(ofSize: size)
    }
    static func pressStart(size: Double) -> UIFont {
        UIFont(name: "PressStart2P-Regular", size: size) ?? .monospacedSystemFont(ofSize: size, weight: .regular)
    }
}

extension Font {
    enum Galmuri {
        case galmuriBold
        case galmuriCondensed
        case pressStart2P

        var value: String {
            switch self {
            case .galmuriBold:      return "Galmuri11-Bold"
            case .galmuriCondensed: return "Galmuri11-Condensed"
            case .pressStart2P:     return "PressStart2P-Regular"
            }
        }
    }
    
    //MARK: Bold
    static func galBold40() -> Font { .custom(Galmuri.galmuriBold.value, size: 40) }
    static func galBold22() -> Font { .custom(Galmuri.galmuriBold.value, size: 22) }
    static func galBold20() -> Font { .custom(Galmuri.galmuriBold.value, size: 20) }
    static func galBold17() -> Font { .custom(Galmuri.galmuriBold.value, size: 17) }
    static func galBold16() -> Font { .custom(Galmuri.galmuriBold.value, size: 16) }
    static func galBold14() -> Font { .custom(Galmuri.galmuriBold.value, size: 14) }
    static func galBold13() -> Font { .custom(Galmuri.galmuriBold.value, size: 13) }
    static func galBold11() -> Font { .custom(Galmuri.galmuriBold.value, size: 11) }
    static func galBold10() -> Font { .custom(Galmuri.galmuriBold.value, size: 10) }
    static func galBold9()  -> Font { .custom(Galmuri.galmuriBold.value, size: 9) }

    //MARK: Press Start 2P
    static func pressStart7() -> Font  { .custom(Galmuri.pressStart2P.value, size: 7) }
    static func pressStart8() -> Font  { .custom(Galmuri.pressStart2P.value, size: 8) }
    static func pressStart9() -> Font  { .custom(Galmuri.pressStart2P.value, size: 9) }
    static func pressStart10() -> Font { .custom(Galmuri.pressStart2P.value, size: 10) }
    static func pressStart12() -> Font { .custom(Galmuri.pressStart2P.value, size: 12) }
    static func pressStart14() -> Font { .custom(Galmuri.pressStart2P.value, size: 14) }
    static func pressStart20() -> Font { .custom(Galmuri.pressStart2P.value, size: 20) }
    static func pressStart34() -> Font { .custom(Galmuri.pressStart2P.value, size: 34) }
    static func pressStart48() -> Font { .custom(Galmuri.pressStart2P.value, size: 48) }

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
    static func galCondensed13() -> Font {
        return .custom(Galmuri.galmuriCondensed.value, size: 13)
    }
}
