//
//  MainCollectionViewCell.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/14.
//

import Foundation
import UIKit

import SnapKit

class MainCollectionViewCell: UICollectionViewCell {
    static let identifier = "colCell"
    
    let todoTableView: UITableView = {
        let view = UITableView()
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.cellSetting()
        self.tableSetting()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cellSetting() {
        self.backgroundColor = .gray
        self.addSubview(todoTableView)
        
        todoTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func tableSetting() {
        todoTableView.register(UITableViewCell.self, forCellReuseIdentifier: "todoTableCell")
        todoTableView.delegate = self
        todoTableView.dataSource = self
    }
    
}

extension MainCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = todoTableView.dequeueReusableCell(withIdentifier: "todoTableCell")
        
        return cell!
    }
    
    
}
