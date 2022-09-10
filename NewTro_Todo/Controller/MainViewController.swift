//
//  MainViewController.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/09.
//

import Foundation
import UIKit

class MainViewController: BaseViewController {
    
    let mainView = MainView()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .mainBackGroundColor
        navigationSetting()
        todoTapGesture()
        habitTapGesture()
        quickNoteTapGesture()
    }
    
    func navigationSetting() {
        let calendarButton = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: self, action: #selector(calendarButtonClicked))
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal"), style: .plain, target: self, action: #selector(menuButtonClicked))
        navigationController?.navigationBar.backgroundColor = .mainBackGroundColor
        navigationItem.leftBarButtonItem = calendarButton
        navigationItem.leftBarButtonItem?.tintColor = .orange
        
        navigationItem.rightBarButtonItem = menuButton
        navigationItem.rightBarButtonItem?.tintColor = .orange
    }
    
    func todoTapGesture() {
        
    }
    
    func habitTapGesture() {
        
    }
    
    func quickNoteTapGesture() {
        
    }
    
    @objc func calendarButtonClicked() {
        
    }
    
    @objc func menuButtonClicked() {
        
    }
    
}
