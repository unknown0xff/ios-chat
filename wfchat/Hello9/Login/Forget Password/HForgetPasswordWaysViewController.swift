//
//  HForgetPasswordWaysViewController.swift
//  Hello9
//
//  Created by Ada on 6/7/24.
//  Copyright © 2024 Hello9. All rights reserved.
//


import UIKit
import Combine

class HForgetPasswordWaysViewController: HBaseViewController {
    
    private lazy var headerView: HLoginHeaderView = {
        let view = HLoginHeaderView(title: "忘记密码", subTitle: "不用担心！忘记密码了，可以选择邮箱或者手机号方式进行验证，并重设密码")
        return view
    }()
    
    private lazy var footerView: HLoginFooterView = {
        let view = HLoginFooterView(title: "记住密码？")
        view.actionButton.addTarget(self, action: #selector(didClickLoginButton(_:)), for: .touchUpInside)
        return view
    }()
    
    private lazy var backgourndView = UIImageView(image: Images.icon_login_background)
    
    private lazy var phoneButton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.setBackgroundImage(Images.icon_blue_background, for: .normal)
        btn.setTitle("通过手机号验证", for: .normal)
        btn.setTitleColor(Colors.white, for: .normal)
        btn.titleLabel?.font = .system16.medium
        
        let icon = UIImageView(image: Images.icon_phone)
        icon.contentMode = .center
        btn.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.equalTo(23)
            make.centerY.equalToSuperview()
            make.height.equalTo(57)
            make.width.equalTo(42)
        }
        
        return btn
    }()
    
    private lazy var emailButton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.backgroundColor = Colors.themeBlack
        btn.layer.cornerRadius = 16
        btn.setTitle("通过电子邮件验证", for: .normal)
        btn.setTitleColor(Colors.white, for: .normal)
        btn.titleLabel?.font = .system16.medium
        
        let icon = UIImageView(image: Images.icon_email)
        icon.contentMode = .center
        btn.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.equalTo(23)
            make.centerY.equalToSuperview()
            make.height.equalTo(57)
            make.width.equalTo(42)
        }
        
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureSubviews() {
        
        view.addSubview(backgourndView)
        
        super.configureSubviews()
        view.addSubview(headerView)
        view.addSubview(phoneButton)
        view.addSubview(emailButton)
        view.addSubview(footerView)
        
        phoneButton.addTarget(self, action: #selector(didClickPhoneButton(_:)), for: .touchUpInside)
        emailButton.addTarget(self, action: #selector(didClickEmailButton(_:)), for: .touchUpInside)
    }
    
    override func makeConstraints() {
        backgourndView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        headerView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom).offset(28)
            make.left.right.equalToSuperview()
        }
        
        emailButton.snp.makeConstraints { make in
            make.bottom.equalTo(-212)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(56)
        }
        
        phoneButton.snp.makeConstraints { make in
            make.height.left.right.equalTo(emailButton)
            make.bottom.equalTo(emailButton.snp.top).offset(-24)
        }
        
        footerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-HUIConfigure.safeBottomMargin)
        }
    }
    
    @objc func didClickPhoneButton(_ sender: UIButton) {
        navigationController?.pushViewController(HForgetPasswordPhoneViewController(), animated: true)
    }
    
    @objc func didClickEmailButton(_ sender: UIButton) {
//        HForgetPasswordPhoneViewController
    }
    
    @objc func didClickLoginButton(_ sender: UIButton) {
        if let nav = navigationController as? HLoginNavigationActions {
            nav.onLoginAction()
        }
    }
    
}

