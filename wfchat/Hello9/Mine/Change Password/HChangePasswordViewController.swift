//
//  HChangePasswordViewController.swift
//  Hello9
//
//  Created by Ada on 2024/7/16.
//  Copyright © 2024 Hello9. All rights reserved.
//


import Combine

class HChangePasswordViewController: HBaseViewController, UICollectionViewDelegate {
    
    private lazy var contentView: UIScrollView = {
        let scrollerView = UIScrollView()
        scrollerView.alwaysBounceVertical = true
        scrollerView.contentInsetAdjustmentBehavior = .never
        scrollerView.keyboardDismissMode = .onDrag
        return scrollerView
    }()
    
    private lazy var currentInputView = buildInput(title: "当前密码", tag: .currentPassword)
    private lazy var passwordView = buildInput(title: "新的密码", tag: .password)
    private lazy var confirmPasswordView = buildInput(title: "确认密码", tag: .confirmPassword)
    
    private lazy var donButtonItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(didClickDoneButton(_:)))
    
    private var currentPassword: String = "" {
        didSet {
            updateDoneButton()
        }
    }
    private var newPassword: String = "" {
        didSet {
            updateDoneButton()
        }
    }
    private var confirmPassword: String = ""{
        didSet {
            updateDoneButton()
        }
    }
    
    private func updateDoneButton() {
        let isValid = !(currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty)
        donButtonItem.isEnabled = isValid
    }
    
    private func buildInput(title: String, tag: InputViewTag) -> HInputView {
        let input = HInputView()
        input.titleLabel.text = title
        input.leftIcon.image = Images.icon_password
        input.textField.attributedPlaceholder = NSAttributedString(string: "请输入8-12位密码", attributes: UITextField.placeHolderAttributes)
        input.textField.tag = tag.rawValue
        input.textField.isSecureTextEntry = true
        input.textField.addTarget(self, action: #selector(didTextFieldValueChange(_:)), for: .editingChanged)
        input.rightButton.setImage(Images.icon_eye_open, for: .normal)
        input.rightButton.addTarget(self, action: #selector(didClickRightButton(_:)), for: .touchUpInside)
        input.rightButton.tag = tag.rawValue
        return input
    }
    
    private enum InputViewTag: Int {
        case currentPassword
        case password
        case confirmPassword
    }
    
    override func didInitialize() {
        super.didInitialize()
        enableAutoHiddenKeybordWhenTouchWhiteSpace = false
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        configureDefaultStyle()
        
        backgroundView.backgroundColor = Colors.white
        navBar.title = "重置密码"
        navBar.rightBarButtonItem = donButtonItem
        donButtonItem.isEnabled = false
        view.addSubview(contentView)
        
        contentView.addSubview(currentInputView)
        contentView.addSubview(passwordView)
        contentView.addSubview(confirmPasswordView)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.left.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        currentInputView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(16)
        }
        
        passwordView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(currentInputView.snp.bottom).offset(23)
        }
        
        confirmPasswordView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(passwordView.snp.bottom).offset(23)
        }
        
    }
    
    @objc func didTextFieldValueChange(_ sender: UITextField) {
        let text = sender.text ?? ""
        if sender.tag == InputViewTag.currentPassword.rawValue {
            currentPassword = text
        } else if sender.tag == InputViewTag.password.rawValue {
            newPassword = text
        } else if sender.tag == InputViewTag.confirmPassword.rawValue {
            confirmPassword = text
        }
    }
    
    @objc func didClickRightButton(_ sender: UIButton) {
        let textField: UITextField
        if sender.tag == InputViewTag.currentPassword.rawValue {
            textField = currentInputView.textField
        } else if sender.tag == InputViewTag.password.rawValue {
            textField = passwordView.textField
        } else {
            textField = confirmPasswordView.textField
        }
        
        textField.isSecureTextEntry.toggle()
        if textField.isSecureTextEntry {
            sender.setImage(Images.icon_eye_open, for: .normal)
        } else {
            sender.setImage(Images.icon_eye_close, for: .normal)
        }
    }
    
    @objc func didClickDoneButton(_ sender: UIBarButtonItem) {
        if newPassword != confirmPassword {
            HToast.showTipAutoHidden(text: "密码不一致，请重新输入")
            return
        }
        
        if newPassword == currentPassword {
            HToast.showTipAutoHidden(text: "当前密码和新密码一致，请重新输入")
            return
        }
        
        let result = newPassword.validate()
        if let first = result.errorMessages.first {
            HToast.showTipAutoHidden(text: first)
            return
        }
        
        let hud = HToast.showLoading("加载中...")
        AppService.shared().changePassword(currentPassword, newPassword: newPassword) { [weak self] in
            hud?.hide(animated: true)
            IMUserInfo.recentCountPwd = self?.newPassword ?? ""
            HToast.showTipAutoHidden(text: "修改成功")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.618) {
                if self?.navigationController?.topViewController == self {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        } error: { _ , msg in
            hud?.hide(animated: true)
            HToast.showTipAutoHidden(text: msg)
        }
    }
}
