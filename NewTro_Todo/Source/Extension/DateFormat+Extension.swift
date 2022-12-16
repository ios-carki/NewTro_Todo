//
//  DateFormat+Extension.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/15.
//

import Foundation
import UIKit

extension UILabel {
    func realmDateFormat() -> String {
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        
        let convertDate = dateFormatter.string(from: nowDate)
        return convertDate
    }
}
