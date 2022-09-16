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
//    let colCell = MainCollectionViewCell()
    var addColCell: [UICollectionViewCell] = []
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: -- Print
        print(addColCell.count)
        print("Realm is located at:", Todo.localRealm.configuration.fileURL!)
        //MARK: -- Print
        view.backgroundColor = .mainBackGroundColor
        navigationSetting()
        collectionSetting()
        todoTapGesture()
        quickNoteTapGesture()
        
        mainView.addColCellBtn.addTarget(self, action: #selector(addColCellButtonClicked), for: .touchUpInside)
        
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
    
    func collectionSetting() {
        mainView.todoCollectionView.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: MainCollectionViewCell.identifier)
        mainView.todoCollectionView.delegate = self
        mainView.todoCollectionView.dataSource = self
    }
    
    func todoTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(todoList))
        mainView.todoView.addGestureRecognizer(tapGesture)
    }
    
    @objc func todoList() {
        print("투두 클릭")
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
        
        self.present(nav, animated: true)
    }
    
    @objc func menuButtonClicked() {
        let vc = SettingViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func addColCellButton() {
        print("버튼눌림")
        mainView.addColCellBtn.addTarget(self, action: #selector(addColCellButtonClicked), for: .touchUpInside)
        print(addColCell.count)
    }
    
    @objc func addColCellButtonClicked() {
        print("버튼눌림")
        addColCell.append(MainCollectionViewCell())
        mainView.todoCollectionView.reloadData()
        print(addColCell.count)
    }
    
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return addColCell.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCollectionViewCell.identifier, for: indexPath)
        
        
        return cell
    }
    
    


}
