//
//  String+Extension.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/10/02.
//

import Foundation

extension String {
    
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
    
    func localized(with argument: CVarArg = [], comment: String = "") -> String {
            return String(format: self.localized(comment: comment), argument)
        }
}
