//
//  CustomNavigationController.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/22/24.
//
import UIKit
import SwiftUI

class CustomNavigationController: UINavigationController,UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.navigationController?.navigationBar.tintColor = UIColor(NewtroColor.mainBackgroundColor)
        viewController.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        viewController.navigationItem.titleView?.tintColor = .white
        //viewController.navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = UIColor(.mainBackgroundColor)
        viewController.navigationController?.navigationBar.shadowImage = UIImage()
        
        let backButton = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        backButton.tintColor = .black
        viewController.navigationItem.backBarButtonItem = backButton
        
        if var textAttributes = viewController.navigationController?.navigationBar.titleTextAttributes {
            textAttributes[NSAttributedString.Key.foregroundColor] = UIColor.black
            viewController.navigationController?.navigationBar.titleTextAttributes = textAttributes
        }
         // MARK: Navigation bar appearance
         let navigationBarAppearance = UINavigationBarAppearance()
         navigationBarAppearance.configureWithOpaqueBackground()
         navigationBarAppearance.titleTextAttributes = [
             NSAttributedString.Key.foregroundColor : UIColor.black
         ]
        navigationBarAppearance.backgroundColor = UIColor(NewtroColor.mainBackgroundColor)
         UINavigationBar.appearance().standardAppearance = navigationBarAppearance
         UINavigationBar.appearance().compactAppearance = navigationBarAppearance
         UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
    }
    
}

class BackBarButtonItem: UIBarButtonItem {
    @available(iOS 14.0, *)
    override var menu: UIMenu? {
        set {
            
        }
        get {
            return super.menu
        }
    }
}
