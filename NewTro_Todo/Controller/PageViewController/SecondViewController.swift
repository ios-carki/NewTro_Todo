//
//  SecondViewController.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/06.
//

import Foundation
import UIKit

class SecondViewController: UIViewController {
    
    let mainView = SecondView()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .mainBackGroundColor
    }
}
