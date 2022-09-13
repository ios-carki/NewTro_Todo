//
//  CalendarViewController.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/12.
//

import Foundation
import UIKit

final class CalendarViewController: BaseViewController {
    
    let mainView = CalendarView()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainBackGroundColor
    }
    
}

