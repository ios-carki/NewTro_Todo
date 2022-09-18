//
//  Alert+Extension.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/13.
//

import Foundation
import UIKit

extension UIViewController {
    
    func customAlertSimple(title: String, message: String, cancelButtonText: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: cancelButtonText, style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    func customActionSheet(title: String?, message: String?, style: UIAlertController.Style = .actionSheet, actions: UIAlertAction...) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        for action in actions {
            alert.addAction(action)
        }
        alert.addAction(cancel)
        
        
        self.present(alert, animated: true)
    }
    
    func customAlert(title: String, message: String, style: UIAlertController.Style = .alert, actions: UIAlertAction...) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        for action in actions {
            alert.addAction(action)
        }
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
}

