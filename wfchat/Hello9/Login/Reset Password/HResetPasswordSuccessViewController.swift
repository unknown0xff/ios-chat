//
//  HResetPasswordSuccessViewController.swift
//  Hello9
//
//  Created by Ada on 6/8/24.
//  Copyright © 2024 Hello9. All rights reserved.
//

import UIKit

class HResetPasswordSuccessViewController: HBaseViewController {
    
    private lazy var loginButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setBackgroundImage(Images.icon_button_background_green, for: .normal)
        btn.setTitle("去登录", for: .normal)
        btn.setTitleColor(Colors.white, for: .normal)
        btn.titleLabel?.font = .system16.bold
        btn.addTarget(self, action: #selector(didClickLoginButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var successView: UIButton = {
        let btn = UIButton.imageButton(
            with: Images.icon_success_green,
            title: "修改成功",
            font: .system20.bold,
            placement: .top)
        btn.isUserInteractionEnabled = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        
        backgroundView.image = Images.icon_background_green
        view.addSubview(successView)
        view.addSubview(loginButton)
        
        successView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(150)
        }
        
        loginButton.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(54)
            make.bottom.equalTo(-13 - HUIConfigure.safeBottomMargin)
        }
    }
    
    @objc func didClickLoginButton(_ sender: UIButton) {
        if let nav = navigationController as? HLoginNavigationActions {
            nav.onLoginAction()
        }
    }
}
