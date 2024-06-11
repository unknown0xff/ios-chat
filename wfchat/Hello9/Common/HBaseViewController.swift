//
//  HBaseViewController.swift
//  Hello9
//
//  Created by Ada on 6/7/24.
//  Copyright © 2024 Hello9. All rights reserved.
//


import UIKit
import Combine

class HBaseViewController: HBasicViewController {
    
    private(set) lazy var navBar: HNavigationBar = {
        let nav = HNavigationBar()
        nav.backButton.addTarget(self, action: #selector(didClickBackBarButton(_:)), for: .touchUpInside)
        return nav
    }()
    
    private(set) lazy var backgroundView = UIImageView(image: Images.icon_common_background)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(backgroundView)
        view.addSubview(navBar)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        configureSubviews()
        makeConstraints()
    }
    
    func configureSubviews() { }
    
    func makeConstraints() { }
    
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

