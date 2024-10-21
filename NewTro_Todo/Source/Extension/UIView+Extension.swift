//
//  UIView+Extension.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/14.
//

import Foundation
import UIKit

extension UIView {
    static func shadowEffect(view: UIView) {
        view.layer.cornerRadius = 10
        
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.mainBackGroundColor.cgColor
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 3, height: 3)
        view.layer.shadowOpacity = 0.7
        view.layer.shadowRadius = 4.0
    }
    
    static func dateFormat(formatType: String) -> String {
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatType
        
        let convertDate = dateFormatter.string(from: nowDate)
        return convertDate
    }
}
