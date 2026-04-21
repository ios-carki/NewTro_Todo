//
//  ThirdViewController.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/06.
//

import Foundation
import UIKit

class ThirdViewController: UIViewController {

    var onFinished: (() -> Void)?

    let mainView = ThirdView()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .mainBackGroundColor
        
        mainView.signupButton.addTarget(self, action: #selector(enterMainView), for: .touchUpInside)
    }
    
    @objc func enterMainView() {
        onFinished?()
    }
        
}
