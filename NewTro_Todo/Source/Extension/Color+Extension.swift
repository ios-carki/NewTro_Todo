import SwiftUI
import UIKit

// MARK: - Design System Palette (Claude Design 확정)

extension UIColor {
    // Sky
    static let skyC          = UIColor(hex: "#7CC7F0")  // 메인 배경
    static let skyDeepC      = UIColor(hex: "#4BA8D8")

    // Ground
    static let grassC        = UIColor(hex: "#6FC44F")
    static let grassDkC      = UIColor(hex: "#3F8D37")
    static let dirtC         = UIColor(hex: "#C88B5A")
    static let dirtDkC       = UIColor(hex: "#8F5A33")

    // Warm Accents
    static let peachC        = UIColor(hex: "#FFB59E")  // 주 버튼 (FAB)
    static let peachDkC      = UIColor(hex: "#E08264")
    static let pinkC         = UIColor(hex: "#FFA3C7")
    static let pinkDkC       = UIColor(hex: "#D46A95")
    static let creamC        = UIColor(hex: "#FFE9B0")
    static let sunC          = UIColor(hex: "#FFCF57")  // 코인, active nav

    // UI
    static let inkC          = UIColor(hex: "#1A1530")  // 텍스트, 테두리
    static let shadeC        = UIColor(hex: "#3B3454")  // 서브 텍스트
    static let panelC        = UIColor(hex: "#FFF7E8")  // 패널 배경
    static let tileC         = UIColor(hex: "#FFD9A8")  // 패널 위 인셋 컨트롤 면
    static let redC          = UIColor(hex: "#E5524E")
    static let redDkC        = UIColor(hex: "#A12F2D")

    // Status
    static let doneC         = UIColor(hex: "#7FD37F")
    static let doneDkC       = UIColor(hex: "#3E8C48")

    // Legacy aliases (기존 UIKit 코드 호환)
    static let mainBackGroundColor          = UIColor(hex: "#7CC7F0")
    static let mainBackGroundColorWithOpacity = UIColor(hex: "#4BA8D8")
    static let cellBackGroundColor          = UIColor(hex: "#4EC8EA")
    static let pageViewBackGroundColor      = UIColor(hex: "#7CC7F0")
    static let coinCountLabelColor          = UIColor(hex: "#FFCF57")
    static let calendarWeekendColor         = UIColor(hex: "#D46A95")
    static let calendarWeekdayColor         = UIColor(hex: "#3F8D37")
    static let cellLabelBackGroundColor     = UIColor(hex: "#8F5A33")
    static let bottomViewBackGroundColor    = UIColor(hex: "#3B3454")

    convenience init(hex: String) {
        var h = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = CGFloat((rgb >> 16) & 0xFF) / 255
        let g = CGFloat((rgb >>  8) & 0xFF) / 255
        let b = CGFloat((rgb >>  0) & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
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

    // Sky
    static let sky          = Color(hex: "#7CC7F0")
    static let skyDeep      = Color(hex: "#4BA8D8")

    // Ground
    static let grass        = Color(hex: "#6FC44F")
    static let grassDk      = Color(hex: "#3F8D37")
    static let grassLt      = Color(hex: "#CFEAC2")
    static let dirt         = Color(hex: "#C88B5A")
    static let dirtDk       = Color(hex: "#8F5A33")

    // Warm Accents
    static let peach        = Color(hex: "#FFB59E")
    static let peachDk      = Color(hex: "#E08264")
    static let pixelPink    = Color(hex: "#FFA3C7")
    static let pinkDk       = Color(hex: "#D46A95")
    static let cream        = Color(hex: "#FFE9B0")
    static let sun          = Color(hex: "#FFCF57")
    static let sunDk        = Color(hex: "#8F6A00")
    static let sunLt        = Color(hex: "#FFE079")

    // UI
    static let ink          = Color(hex: "#1A1530")
    static let shade        = Color(hex: "#3B3454")
    static let panel        = Color(hex: "#FFF7E8")
    static let tile         = Color(hex: "#FFD9A8")
    static let pixelRed     = Color(hex: "#E5524E")
    static let redDk        = Color(hex: "#A12F2D")
    static let redLt        = Color(hex: "#F7B5B2")

    // Status
    static let done         = Color(hex: "#7FD37F")
    static let doneDk       = Color(hex: "#3E8C48")

    // Legacy aliases
    static let placeHolderC    = Color(hex: "#929292")
    static let mainBackGroundC = Color(hex: "#7CC7F0")
    static let textFieldC      = Color(hex: "#4EC8EA")
}
