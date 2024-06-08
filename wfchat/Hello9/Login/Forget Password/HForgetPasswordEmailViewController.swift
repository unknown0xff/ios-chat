//
//  HForgetPasswordEmailViewController.swift
//  Hello9
//
//  Created by Ada on 6/8/24.
//  Copyright © 2024 Hello9. All rights reserved.
//

import UIKit
import Combine

class HForgetPasswordEmailViewController: HBaseViewController {
    
    private lazy var headerView: HLoginHeaderView = {
        let view = HLoginHeaderView(title: "忘记密码", subTitle: "请输入电子邮件，我们将想您的邮箱发送一封带有验证邮件～")
        return view
    }()
    
    private lazy var footerView: HLoginFooterView = {
        let view = HLoginFooterView(title: "记住密码？")
        view.actionButton.addTarget(self, action: #selector(didClickLoginButton(_:)), for: .touchUpInside)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system16.bold
        label.textColor = Colors.themeBlack
        label.text = "请输入邮箱地址"
        return label
    }()
    
    private lazy var leftContent: UIStackView = {
        let s = UIStackView()
        s.alignment = .center
        s.distribution = .fill
        
        let leadingSpace = UILabel()
        leadingSpace.snp.makeConstraints { make in
            make.width.equalTo(24)
        }
        s.addArrangedSubview(leadingSpace)
        
        let imageView = UIImageView(image: Images.icon_email_black)
        s.addArrangedSubview(imageView)
        s.setCustomSpacing(14, after: imageView)
        imageView.snp.makeConstraints { make in
            make.width.equalTo(23)
        }
        
        s.addArrangedSubview(UIView.gapView)
        
        return s
    }()
    
    private lazy var stack: UIStackView = {
        let s = UIStackView()
        s.alignment = .center
        s.distribution = .fill
        s.spacing = 12
        s.backgroundColor = Colors.grayF6
        s.layer.cornerRadius = 16
        return s
    }()
    
    private lazy var textField: UITextField = {
        let field = UITextField.default
        field.placeholder = "请输入您的邮箱地址"
        field.keyboardType = .emailAddress
        return field
    }()
    
    private lazy var nextStepButton: UIButton = .loginButton
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        nextStepButton.addTarget(self, action: #selector(didClickNextStepButton(_:)), for: .touchUpInside)
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        view.addSubview(headerView)
        
        view.addSubview(titleLabel)
        
        stack.addArrangedSubview(leftContent)
        stack.addArrangedSubview(textField)
        
        view.addSubview(stack)
        view.addSubview(nextStepButton)
        view.addSubview(footerView)
        
        nextStepButton.isEnabled = !((textField.text ?? "").isEmpty)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        headerView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom).offset(28)
            make.left.right.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.top.equalTo(headerView.snp.bottom).offset(50)
            make.height.equalTo(26)
        }
        
        stack.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.height.equalTo(54)
        }
        
        nextStepButton.snp.makeConstraints { make in
            make.top.equalTo(stack.snp.bottom).offset(90)
            make.width.height.equalTo(62)
            make.centerX.equalToSuperview()
        }
        
        footerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-HUIConfigure.safeBottomMargin)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        nextStepButton.isEnabled = !text.isEmpty
    }
    
    @objc func didClickNextStepButton(_ sender: UIButton) {
        let vc = HVerifyCodeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didClickLoginButton(_ sender: UIButton) {
        if let nav = navigationController as? HLoginNavigationActions {
            nav.onLoginAction()
        }
    }
}

