//
//  SplashViewController.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/12/07.
//

import UIKit

final class SplashViewController: UIViewController {
    
    private let mainView = SplashView()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flashLabel()
    }
    
    func flashLabel() {
        mainView.splashLabel.text = ""
        var charIndex = 0.0
        let splashText = "NewTro\nToDo!"
        
        for letter in splashText {
            Timer.scheduledTimer(withTimeInterval: 0.2 * charIndex, repeats: false) { timer in
                self.mainView.splashLabel.text?.append(letter)
            }
            charIndex += 1
        }
        
    }
}
