//
//  ThirdViewController.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/06.
//

import Foundation
import UIKit

class ThirdViewController: UIViewController {
    
    let mainView = ThirdView()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        mainView.signupButton.addTarget(self, action: #selector(enterMainView), for: .touchUpInside)
    }
    
    @objc func enterMainView() {
        let vc = MainViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen //풀스크린 모달방식
        
        let firstLaunch = UserDefaults.standard.bool(forKey: "oldUser")
        if firstLaunch {
            
        } else {
            UserDefaults.standard.set(true, forKey: "oldUser")
        }
        
        
        self.present(nav, animated: true)
    }
        
}
