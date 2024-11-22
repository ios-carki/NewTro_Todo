//
//  UIApplication+Extension.swift
//  NewTro_Todo
//
//  Created by OWEN on 11/18/24.
//

import UIKit

extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
