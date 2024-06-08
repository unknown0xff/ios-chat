//
//  HVerifyCodeViewController.swift
//  Hello9
//
//  Created by Ada on 6/7/24.
//  Copyright © 2024 Hello9. All rights reserved.
//

import UIKit
import Combine

class HVerifyCodeViewController: HBaseViewController, HVerifyCodeViewDelegate {

    private lazy var headerView: HLoginHeaderView = {
        let view = HLoginHeaderView(title: "请输入验证码", subTitle: "验证码已发送至 +96 139 0000 0000")
        return view
    }()
    
    private lazy var footerView: HLoginFooterView = {
        let view = HLoginFooterView(title: "记住密码？")
        view.actionButton.addTarget(self, action: #selector(didClickLoginButton(_:)), for: .touchUpInside)
        return view
    }()
    
    private lazy var backgourndView = UIImageView(image: Images.icon_login_background)
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system16.bold
        label.textColor = Colors.themeBlack
        label.text = "请输入验证码"
        return label
    }()
    
    private lazy var verifyCodeView: HVerifyCodeView = {
        let code = HVerifyCodeView(frame: .zero, verifyCount: 4)
        code.delegate = self
        return code
    }()
    
    private lazy var nextButton: UIButton = .loginButton
    private lazy var countDownButton: HCountDownButton = .init(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countDownButton.startTime(secondsCountDown: 60)
        countDownButton.addTarget(self, action: #selector(didClickResendButton(_:)), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didClickNextButton(_:)), for: .touchUpInside)
    }
    
    override func configureSubviews() {
        
        view.addSubview(backgourndView)
        
        super.configureSubviews()
        view.addSubview(headerView)
        
        view.addSubview(titleLabel)
        view.addSubview(countDownButton)
        view.addSubview(verifyCodeView)
        view.addSubview(nextButton)
        view.addSubview(footerView)
    }
    
    override func makeConstraints() {
        
        backgourndView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        headerView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom).offset(28)
            make.left.right.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.top.equalTo(headerView.snp.bottom).offset(50)
            make.height.equalTo(26)
        }
        
        countDownButton.snp.makeConstraints { make in
            make.right.equalTo(-30)
            make.centerY.equalTo(titleLabel)
        }
        
        verifyCodeView.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.height.equalTo(54)
        }
        
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(verifyCodeView.snp.bottom).offset(90)
            make.width.height.equalTo(62)
            make.centerX.equalToSuperview()
        }
        
        footerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-HUIConfigure.safeBottomMargin)
        }
    }
    
    func verificationCodeDidFinishInput(code: String) {
        nextButton.isEnabled = code.count == 4
    }
    
    @objc func didClickResendButton(_ sender: UIButton) {
        verifyCodeView.cleanVerifyCodeView()
        countDownButton.startTime(secondsCountDown: 60)
    }
    
    @objc func didClickNextButton(_ sender: UIButton) {
        navigationController?.pushViewController(HResetPasswordViewController(), animated: true)
    }
    
    @objc func didClickLoginButton(_ sender: UIButton) {
        if let nav = navigationController as? HLoginNavigationActions {
            nav.onLoginAction()
        }
    }
    
}

