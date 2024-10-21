//
//  CalendarCell.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/15/24.
//

import Foundation

import FSCalendar
import SnapKit

class CalendarCell: FSCalendarCell {
    
    var backImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.titleLabel.snp.makeConstraints { make in
            make.center.equalTo(contentView)
        }
        
        contentView.insertSubview(backImageView, at: 0)
        backImageView.snp.makeConstraints { make in
            make.center.equalTo(contentView)
            make.size.equalTo(40)
        }
    }
    
    required init(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        backImageView.image = nil
    }
    
    // 셀의 높이와 너비 중 작은 값을 리턴한다
//    func minSize() -> CGFloat {
//        let width = 16
//        let height = 16
//
//        return (width > height) ? height : width
//    }
}
