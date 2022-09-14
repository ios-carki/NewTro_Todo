//
//  TodoWriteView.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/14.
//

import Foundation
import UIKit

import FSCalendar

final class TodoWriteView: BaseView {
    let writeScrollView: UIScrollView = {
        let view = UIScrollView()
        
        return view
    }()
    
    let writeCalendar: FSCalendar = {
        let view = FSCalendar()
        
        return view
    }()
    
    let selectedDateHeaderLabel: UILabel = {
        let view = UILabel()
        view.text = "선택된 날짜"
        return view
    }()
    
    let selectedDateLabel: UILabel = {
        let view = UILabel()
        
        return view
    }()
    
    //세그먼트 2개로 하기
    //세그1.투두, 습관, 퀵노트
    //세그2.등록날짜순, 중요도높은순
    //중요도 상중하 나눠서 중요도 높은 순서대로 보여주기 -> 중요도 상에 해당되는 최신순
    let importanceHeaderLabel: UILabel = {
        let view = UILabel()
        view.text = "중요도 설정"
        return view
    }()
    
    let importanceSelectButton: UIButton = {
        let view = UIButton()
        view.setTitle("선택", for: .normal)
        return view
    }()
    
    let importanceSelectText: UILabel = {
        let view = UILabel()
        view.text = "하"
        return view
    }()
    
    let titleHeaderLabel: UILabel = {
        let view = UILabel()
        view.text = "제목"
        return view
    }()

    let titleTextView: UITextView = {
        let view = UITextView()
        
        return view
    }()
    
    let context: UITextView = {
        let view = UITextView()
        
        return view
    }()
    
    override func configureUI() {
        
    }
    
    override func setConstraints() {
        
    }
}
