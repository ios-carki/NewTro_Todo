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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mainBackGroundColor]
    }
    
    func navigationSetting() {
        let calendarButton = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: self, action: #selector(calendarButtonClicked))
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal"), style: .plain, target: self, action: #selector(menuButtonClicked))
        
        title = "메인"
        navigationController?.navigationBar.backgroundColor = .mainBackGroundColor
        navigationItem.leftBarButtonItem = calendarButton
        navigationItem.leftBarButtonItem?.tintColor = .orange
        
        navigationItem.rightBarButtonItem = menuButton
        navigationItem.rightBarButtonItem?.tintColor = .orange
    }
    
    func todoTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(todoList))
        mainView.todoView.addGestureRecognizer(tapGesture)
    }
    
    @objc func todoList() {
        print("투두 클릭")
    }
    
    func habitTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(habit))
        mainView.habitView.addGestureRecognizer(tapGesture)
    }
    
    @objc func habit() {
        print("습관 클릭")
    }
    
    func quickNoteTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(quickNote))
        mainView.quickNoteView.addGestureRecognizer(tapGesture)
    }
    
    @objc func quickNote() {
        print("퀵노트 클릭")
    }
    
    @objc func calendarButtonClicked() {
        let vc = CalendarViewController()
        let nav = UINavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .popover
//        nav.modalTransitionStyle = .flipHorizontal
//        vc.modalTransitionStyle = .crossDissolve
        
        self.present(nav, animated: true)
    }
    
    @objc func menuButtonClicked() {
        let vc = SettingViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
