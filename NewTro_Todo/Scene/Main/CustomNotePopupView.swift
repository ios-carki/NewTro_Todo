//
//  CustomNotePopupView.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/27.
//

import Foundation
import UIKit
import CoreGraphics

import SnapKit

class CustomNotePopupView: BaseView {
    
    let noteView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    let noteNameLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .mainBackGroundColor
        view.text = "NoteNameLabel_Text".localized()
        view.textColor = .white
        view.textAlignment = .center
        view.font = .mainFont(size: 20)
        return view
    }()
    
    let noteCancelButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "xmark"), for: .normal)
        view.tintColor = .black
        view.backgroundColor = .mainBackGroundColor
        return view
    }()
    
    let noteTextView: UITextView = {
        let view = UITextView()
        view.font = .mainFont(size: 16)
        return view
    }()
    
    let noteSaveButton: UIButton = {
        let view = UIButton()
        view.setTitle("NoteSaveButton_SetTitle".localized(), for: .normal)
        view.titleLabel?.font = .mainFont(size: 20)
        view.tintColor = .black
        view.backgroundColor = .mainBackGroundColor
        return view
    }()
    
    override func configureUI() {
        self.backgroundColor = .black.withAlphaComponent(0.2)
        
        noteView.addSubview(noteNameLabel)
        noteView.addSubview(noteCancelButton)
        noteView.addSubview(noteTextView)
        noteView.addSubview(noteSaveButton)
        
        [noteView].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        
        noteView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.size.width / 1.5)
            make.height.equalTo(UIScreen.main.bounds.size.height / 2.5)
        }
        
        noteNameLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(noteCancelButton.snp.height)
        }
        
        noteCancelButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.bottom.equalTo(noteTextView.snp.top)
            make.width.equalTo(35)
            make.height.equalTo(35)
        }
        
        noteTextView.snp.makeConstraints { make in
            make.top.equalTo(noteNameLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(noteSaveButton.snp.top)
        }
        
        noteSaveButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(35)
        }
    }
}
 
