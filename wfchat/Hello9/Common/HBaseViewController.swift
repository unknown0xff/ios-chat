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
    
    private(set) lazy var navBarBackgroundView = UIImageView(image: Images.icon_common_background)
    private(set) lazy var backgroundView = UIImageView(image: Images.icon_background_gray)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(_onUserInfoUpdated(_:)), name: .init(kUserInfoUpdated), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_onGroupInfoUpdated(_:)), name: .init(kGroupInfoUpdated), object: nil)
        
        view.addSubview(backgroundView)
        view.addSubview(navBarBackgroundView)
        view.addSubview(navBar)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        navBarBackgroundView.snp.makeConstraints { make in
            make.width.top.left.right.equalToSuperview()
            make.height.equalTo(navBarBackgroundView.snp.width).multipliedBy(584.0 / 750.0)
        }
        
        configureSubviews()
        makeConstraints()
    }
    
    func configureDefaultStyle() {
        navBarBackgroundView.isHidden = true
        view.bringSubviewToFront(navBar)
        backgroundView.image = nil
        backgroundView.backgroundColor = Colors.themeGray6
    }
    
    func configureSubviews() { }
    
    func makeConstraints() { }
    
    override func setupBackButton() {
        if presentingViewController != nil || (navigationController != nil && navigationController!.viewControllers.count > 1) {
            if backButtonImage != nil {
                navBar.leftBarButtonItem = .init(image: backButtonImage, style: .plain, target: self, action: #selector(didClickBackBarButton(_:)))
            } else {
                navBar.leftBarButtonItem = nil
            }
        } else {
            navBar.leftBarButtonItem = nil
        }
        
        navBar.backButton.isHidden = true
    }
    
    func onUserInfoUpdated(_ sender: Notification) { }
    func onGroupInfoUpdated(_ sender: Notification) { }
    func onCurrentUserInfoChange(_ userInfo: WFCCUserInfo) { }
    
    override func prefersNavigationBarHidden() -> Bool { true }
    
    @objc private func _onUserInfoUpdated(_ sender: Notification) {
        
        if let infoList = sender.userInfo?["userInfoList"] as? [WFCCUserInfo] {
            let current = infoList.first { userInfo in
                userInfo.userId == WFCCNetworkService.sharedInstance().userId
            }
            if let current {
                onCurrentUserInfoChange(current)
            }
        }
        
        onUserInfoUpdated(sender)
    }
    
    @objc private func _onGroupInfoUpdated(_ sender: Notification) { 
        onGroupInfoUpdated(sender)
    }
    
}

