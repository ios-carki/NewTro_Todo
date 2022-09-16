//
//  TablePlusCell.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/15.
//

import Foundation
import UIKit

import SnapKit

class TablePlusCell: UITableViewCell {
    static let identifier = "tablePlusCell"
    
    @objc let plusButton: UIButton = {
        let view = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .light)
        let image = UIImage(systemName: "plus", withConfiguration: imageConfig)
        
        view.backgroundColor = .brown
        view.setImage(image, for: .normal)
            
        return view
    }()
    
    var test: ( () -> () )?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
        setLayout()
        plusButton.addTarget(self, action: #selector(plusButtonClicked), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        contentView.addSubview(plusButton)
    }
    
    private func setLayout() {
        plusButton.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(safeAreaLayoutGuide)
            make.height.width.equalTo(40)
        }
    }
    
    @objc func plusButtonClicked() {
        print("셀 추가버튼 눌림")
        MainCollectionViewCell.tableTodoData.append(TablePlusCell.identifier)
        MainCollectionViewCell().todoTableView.snp.makeConstraints { make in
            make.height.equalTo(MainCollectionViewCell().todoTableView.contentSize.height)
        }
//        MainCollectionViewCell().todoTableView.reloadSections(IndexSet(0...0), with: .automatic)
        MainCollectionViewCell().todoTableView.reloadData()
        test?()
        //
        print(MainCollectionViewCell.tableTodoData.count)
    }
    
}
