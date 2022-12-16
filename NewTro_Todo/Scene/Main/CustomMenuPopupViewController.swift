//
//  CustomMenuPopupViewController.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/20.
//

import Foundation

import RealmSwift

class CustomMenuPopupViewController: BaseViewController {
    
    let mainView = CustomMenuPopupView()
    let subView = MainView()
    
    var receivedTag: Int?
    var id: ObjectId?
    var localRealm = try! Realm()
    var tasks: Results<Todo>! {
        didSet {
            subView.tableView.reloadData()
            print("데이터 변함!")
        }
    }
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainView.cancelButton.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        mainView.setImportanceButton.addTarget(self, action: #selector(importanceButtonClicked), for: .touchUpInside)
        mainView.setFavoriteButton.addTarget(self, action: #selector(favoriteButtonClicked), for: .touchUpInside)
        mainView.deleteButton.addTarget(self, action: #selector(deleteButtonClicked), for: .touchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if tasks[receivedTag!].importance == 0 {
            mainView.setImportanceStatusLable.text = "tasks[receivedTag!].importance_0".localized()
        }else if tasks[receivedTag!].importance == 1 {
            mainView.setImportanceStatusLable.text = "tasks[receivedTag!].importance_1".localized()
        }else {
            mainView.setImportanceStatusLable.text = "tasks[receivedTag!].importance_2".localized()
        }
        
        print("페이보릿 상태 확인: ", tasks[receivedTag!].favorite)
        if tasks[receivedTag!].favorite {
            mainView.setFavoriteStatusLabel.text = "tasks[receivedTag!].favorite_ON".localized()
        } else {
            mainView.setFavoriteStatusLabel.text = "tasks[receivedTag!].favorite_OFF".localized()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name("DismissDetailView"), object: nil, userInfo: nil)
    }
    
    
    @objc func cancelButtonClicked() {
        
        dismiss(animated: false)
    }
    
    //MARK: --공부하기(버튼에 대한 태그전달)
    @objc func importanceButtonClicked() {
        
        //MARK: --공부하기(버튼에 대한 태그전달) tasks[receivedTag!].importance
        if tasks[receivedTag!].importance == 0 {
            try! self.localRealm.write {
                tasks[receivedTag!].importance = 1
            }
            mainView.setImportanceStatusLable.text = "tasks[receivedTag!].importance_1".localized()
//            subView.tableView.reloadData()
        } else if tasks[receivedTag!].importance == 1 {
            try! self.localRealm.write {
                tasks[receivedTag!].importance = 2
            }
            mainView.setImportanceStatusLable.text = "tasks[receivedTag!].importance_2".localized()
//            subView.tableView.reloadData()
        } else if tasks[receivedTag!].importance == 2 {
            try! self.localRealm.write {
                tasks[receivedTag!].importance = 0
            }
            mainView.setImportanceStatusLable.text = "tasks[receivedTag!].importance_0".localized()
//            subView.tableView.reloadData()
        }
    }
    //MARK: --공부하기(버튼에 대한 태그전달)
    
    @objc func favoriteButtonClicked() {
        try! self.localRealm.write {
            tasks[receivedTag!].favorite.toggle()
        }
        
        if tasks[receivedTag!].favorite {
            mainView.setFavoriteStatusLabel.text = "tasks[receivedTag!].favorite_ON".localized()
        } else {
            mainView.setFavoriteStatusLabel.text = "tasks[receivedTag!].favorite_OFF".localized()
        }
        
//        subView.tableView.reloadData()
    }
    
    @objc func deleteButtonClicked() {
        try! self.localRealm.write {
            localRealm.delete(tasks[receivedTag!])
        }
        dismiss(animated: false)
    }
}
