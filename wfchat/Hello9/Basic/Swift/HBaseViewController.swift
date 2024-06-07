//
//  HBaseViewController.swift
//  Hello9
//
//  Created by Ada on 6/7/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//


import UIKit
import Combine

class HBaseViewController: HBasicViewController {
    
    private(set) lazy var navBar: HNavigationBar = {
        let nav = HNavigationBar()
        nav.backButton.addTarget(self, action: #selector(didClickBackBarButton(_:)), for: .touchUpInside)
        return nav
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        makeConstraints()
    }
    
    func configureSubviews() {
        view.addSubview(navBar)
    }
    
    func makeConstraints() {
        
    }
    
    override func setupBackButton() {
        if presentingViewController != nil || (navigationController != nil && navigationController!.viewControllers.count > 1) {
            if backButtonImage != nil {
                navBar.backButton.isHidden = false
                navBar.backButton.setImage(backButtonImage, for: .normal)
            } else {
                navBar.backButton.isHidden = true
            }
        } else {
            navBar.backButton.isHidden = true
        }
    }
    
    override func prefersNavigationBarHidden() -> Bool { true }
}

