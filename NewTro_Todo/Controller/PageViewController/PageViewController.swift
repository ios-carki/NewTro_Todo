//
//  PageViewController.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/06.
//

import Foundation
import UIKit

import SnapKit

class PageViewController: UIPageViewController {
    
    //네비게이션
    lazy var navigationView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainBackGroundColor
        
        return view
    }()
    
    //페이지뷰에 쓰이는 뷰컨3개
    var pageViewControllerList: [UIViewController] = [FirstViewController(), SecondViewController(), ThirdViewController()]
    
    lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
        configure()
        
    }
    
    func setupDelegate() {
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        if let firstVC = pageViewControllerList.first {
            pageViewController.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    private func configure() {
//        view.addSubview(navigationView)
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        
//        navigationView.snp.makeConstraints { make in
//            make.width.top.equalToSuperview()
//            make.height.equalTo(72)
//        }
        
//        pageViewController.view.snp.makeConstraints { make in
//            make.top.equalTo(navigationView.snp.bottom)
//            make.leading.trailing.bottom.equalToSuperview()
//        }
        
        pageViewController.view.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        pageViewController.didMove(toParent: self)
    }
}

extension PageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pageViewControllerList.firstIndex(of: viewController) else { return nil }
        let previousIndex = index - 1
        if previousIndex < 0 {
            return nil
        }
        
        return pageViewControllerList[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pageViewControllerList.firstIndex(of: viewController) else { return nil }
        let nextIndex = index + 1
        if nextIndex == pageViewControllerList.count {
            return nil
        }
        return pageViewControllerList[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pageViewControllerList.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let first = viewControllers?.first, let index = pageViewControllerList.firstIndex(of: first) else { return 0 }
        
        return index
    }
    
    
    
}
