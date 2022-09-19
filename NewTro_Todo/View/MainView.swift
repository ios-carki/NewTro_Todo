//
//  MainView.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/09.
//

import Foundation
import UIKit

import SnapKit

class MainView: BaseView {
    
    let mainBackgroundImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "MainBackGround")
        view.contentMode = .scaleToFill
        return view
    }()
    
    let coinImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "Coin")
        return view
    }()
    
    let coinCountLabel: UILabel = {
        let view = UILabel()
        
        view.font = .boldFont(size: 20)
        view.text = dateFormat(formatType: "yyMMdd")
        view.textColor = .coinCountLabelColor
        return view
    }()
    
    let heartImage1: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "Heart")
        return view
    }()
    
    let heartImage2: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "Heart")
        return view
    }()
    
    let heartImage3: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "Heart")
        return view
    }()
    
    //MARK: -- Todobtn
    let todoView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainBackGroundColor
        shadowEffect(view: view)
        return view
    }()
    
    let todoImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "TodoList")
        view.contentMode = .scaleToFill
        return view
    }()
    
    let todoLabel: UILabel = {
        let view = UILabel()
        view.text = "할 일 작성 목록"
        view.font = .mainFont(size: 20)
        view.textAlignment = .center
        return view
    }()
    //MARK: -- Todobtn
    
    //MARK: -- QuickNotebtn
    let quickNoteView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainBackGroundColor
        shadowEffect(view: view)
        return view
    }()
    
    let quickNoteImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "QuickNote")
        view.contentMode = .scaleToFill
        return view
    }()
    
    let quickNoteLabel: UILabel = {
        let view = UILabel()
        view.text = "퀵노트 목록"
        view.font = .mainFont(size: 20)
        view.textAlignment = .center
        return view
    }()
    //MARK: -- QuickNotebtn
    
    //MARK: -- bottomView
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainBackGroundColor
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()
    
    //추가
    let leftButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "arrowtriangle.left.fill"), for: .normal)
        return view
    }()
    
    let datePickBtn: UIButton = {
        let view = UIButton()
        view.setTitle(dateFormat(formatType: "yyyy년 MM월 dd일"), for: .normal)
        view.titleLabel?.font = .boldFont(size: 17)
        view.titleLabel?.textAlignment = .center
        view.titleLabel?.textColor = .black
        return view
    }()
    
    let rightButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "arrowtriangle.right.fill"), for: .normal)
        return view
    }()
    
    let boundaryLine: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    let tableView: UITableView = {
        let view = UITableView()
        return view
    }()
    
//    let todoCollectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//
//        //셀의 가로 넓이는 메인뷰의 여백을 제외한 넓이 * 보여주시고 싶은 비율
//        let cellSize: CGFloat = (UIScreen.main.bounds.width - 40) * 0.9
//        //높이는 추후에 delegate에서 수정!
//        layout.itemSize = CGSize(width: cellSize, height: 400)
//
//        layout.minimumInteritemSpacing = 5
//        layout.minimumLineSpacing = 5
//        layout.scrollDirection = .horizontal
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
//
//        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        view.backgroundColor = .red
//        return view
//    }()
    
    //MARK: -- bottomView
    
//    func collectionViewConfigure() {
//        todoCollectionView.
//    }
    
    override func configureUI() {
        todoView.addSubview(todoImage)
        todoView.addSubview(todoLabel)
        
        quickNoteView.addSubview(quickNoteImage)
        quickNoteView.addSubview(quickNoteLabel)
        
        bottomView.addSubview(leftButton)
        bottomView.addSubview(datePickBtn)
        bottomView.addSubview(rightButton)
        bottomView.addSubview(boundaryLine)
        bottomView.addSubview(tableView)
        
        [todoView, quickNoteView, bottomView, mainBackgroundImage, coinImage, coinCountLabel, heartImage1, heartImage2, heartImage3].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        
        mainBackgroundImage.snp.makeConstraints { make in
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
            make.height.equalTo(100)
        }
        
        coinImage.snp.makeConstraints { make in
            make.top.leading.equalTo(safeAreaLayoutGuide).offset(5)
            make.height.width.equalTo(50)
        }
        
        coinCountLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(19)
            make.leading.equalTo(coinImage.snp.trailing)
        }
        
        heartImage1.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(5)
            make.trailing.equalTo(heartImage2.snp.leading).offset(20)
            make.height.width.equalTo(50)
        }
        
        heartImage2.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(5)
            make.trailing.equalTo(heartImage3.snp.leading).offset(20)
            make.height.width.equalTo(50)
        }
        
        heartImage3.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(5)
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-5)
            make.height.width.equalTo(50)
        }
        
        //MARK: -- Todo
        todoView.snp.makeConstraints { make in
            make.top.equalTo(coinImage.snp.bottom)
            make.leading.equalTo(safeAreaLayoutGuide).offset(40)
            make.height.equalTo(80)
            make.width.equalTo(120)
        }
        
        todoImage.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(todoView.safeAreaLayoutGuide)
        }
        
        todoLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(todoView.safeAreaLayoutGuide)
            make.top.equalTo(todoImage.snp.bottom)
            make.height.equalTo(20)
        }
        //MARK: -- Todo
        
        //MARK: -- QuickNote
        quickNoteView.snp.makeConstraints { make in
            make.top.equalTo(coinImage.snp.bottom)
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-40)
            make.height.equalTo(80)
            make.width.equalTo(120)
        }
        
        quickNoteImage.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(quickNoteView.safeAreaLayoutGuide)
        }
        
        quickNoteLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(quickNoteView.safeAreaLayoutGuide)
            make.top.equalTo(quickNoteImage.snp.bottom)
            make.height.equalTo(20)
        }
        //MARK: -- QuickNote
        
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(todoView.snp.bottom).offset(12)
            make.leading.equalTo(safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-20)
            make.bottom.equalTo(mainBackgroundImage.snp.top)
        }
        
        leftButton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(12)
            make.bottom.equalTo(boundaryLine.snp.top).offset(-8)
        }
        
        datePickBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(boundaryLine.snp.top).offset(-8)
        }
        
        rightButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.bottom.equalTo(boundaryLine.snp.top).offset(-8)
            make.trailing.equalToSuperview().offset(-12)
        }
        boundaryLine.snp.makeConstraints { make in
            make.leading.equalTo(bottomView.safeAreaLayoutGuide).offset(8)
            make.trailing.equalTo(bottomView.safeAreaLayoutGuide).offset(-8)
            make.height.equalTo(1)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(boundaryLine.snp.bottom)
            make.leading.trailing.bottom.equalTo(bottomView.safeAreaLayoutGuide)
        }
        
    }
    
}
