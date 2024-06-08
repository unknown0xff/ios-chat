//
//  HLoginInputCell.swift
//  ios-hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import UIKit

protocol HLoginInputCellDelegate: AnyObject {
    func didChangeInputValue(_ value: HLoginInputModel, at indexPath: IndexPath)
    func didClickRefreshButton(_ completion: ((Bool) -> Void)?)
}

extension HLoginInputCellDelegate {
    func didClickRefreshButton(_ completion: ((Bool) -> Void)?) { }
}


class HLoginInputCell: HBasicTableViewCell<HLoginInputModel> {

    weak var delegate: HLoginInputCellDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system14
        label.textColor = Colors.themeGray2
        return label
    }()
    
    private lazy var stack: UIStackView = {
        let s = UIStackView()
        s.alignment = .center
        s.distribution = .fill
        s.backgroundColor = Colors.grayF6
        s.layer.cornerRadius = 16
        return s
    }()
    
    private lazy var textField: UITextField = {
        let field = UITextField.default
        return field
    }()
    
    private lazy var leftIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    
    private lazy var rightButton: UIButton = {
        let btn = UIButton(type: .system)
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureSubviews() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(titleLabel)
        contentView.addSubview(stack)
        
        stack.addArrangedSubview(leftIcon)
        
        let space = UIView()
        space.backgroundColor = Colors.grayD1
        stack.addArrangedSubview(space)
        space.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(16)
        }
        
        stack.setCustomSpacing(12, after: space)
        stack.addArrangedSubview(textField)
        stack.addArrangedSubview(rightButton)
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        rightButton.addTarget(self, action: #selector(didClickRightButton(_:)), for: .touchUpInside)
    }
    
    private func makeConstraints() {
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.top.equalTo(13)
            make.height.equalTo(22)
        }
        
        stack.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.left)
            make.right.equalTo(-30)
            make.height.equalTo(54)
            make.bottom.equalTo(-13)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        leftIcon.snp.makeConstraints { make in
            make.width.equalTo(57)
            make.height.equalTo(42)
        }
        
        rightButton.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalToSuperview()
        }
    }
    
    override func bindData(_ data: HLoginInputModel?) {
        guard let data else {
            return
        }
        
        leftIcon.image = data.leftImage
        textField.text = data.value
        textField.attributedPlaceholder = data.placeholder
        titleLabel.text = data.title
        
        textField.keyboardType = data.keyboardType
        textField.isSecureTextEntry = data.isSecureTextEntry
        
        if data.shouldShowRightImage {
            let image = textField.isSecureTextEntry ? Images.icon_eye_open : Images.icon_eye_close
            rightButton.setImage(image, for: .normal)
            rightButton.isHidden = false
        } else {
            rightButton.isHidden = true
        }
        
        if data.isNewUser {
            textField.isEnabled = false
        } else {
            textField.isEnabled = true
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        cellData?.value = textField.text ?? ""
        guard let cellData else {
            return
        }
        delegate?.didChangeInputValue(cellData, at: indexPath)
    }
    
    @objc func didClickRightButton(_ sender: UIButton) {
        
        guard var data = cellData else {
            return
        }
        
        // 登录且是密码输入框，更新isSecureTextEntry
        if !data.isNewUser && (data.id == .password || data.id == .passwordConfirm) {
            data.isSecureTextEntry.toggle()
            cellData = data
            delegate?.didChangeInputValue(data, at: indexPath)
            return
        }
        
        startRotation()
        
        DispatchQueue.global().async {
            self.delegate?.didClickRefreshButton { _ in
                DispatchQueue.main.async {
                    self.stopRotation()
                }
            }
        }
    }
    
    func startRotation() {
        rightButton.isEnabled = false
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = CGFloat.pi * 2
        rotationAnimation.duration = 1
        rotationAnimation.repeatCount = .infinity
        
        if let imageView = rightButton.imageView {
            imageView.layer.add(rotationAnimation, forKey: "rotationAnimation")
        }
    }
    
    func stopRotation() {
        rightButton.isEnabled = true
        if let imageView = rightButton.imageView {
            imageView.layer.removeAnimation(forKey: "rotationAnimation")
        }
    }
}

fileprivate extension HLoginInputModel {
    
    var title: String {
        switch id {
        case .account:
            return isNewUser ? "创建账户" : "Hello9账户"
        case .password:
            return isNewUser ? "账户密码" : "账户密码"
        case .passwordConfirm:
            return "重新输入账户密码"
        }
    }
    
    var leftImage: UIImage {
        id == .account ? Images.icon_account : Images.icon_password
    }
    
    var shouldShowRightImage: Bool {
        switch id {
        case .account:
            return false
        case .password, .passwordConfirm:
            return isNewUser ? false : true
        }
    }
    
    var placeholder: NSAttributedString {
        let str = id == .account ? "请输入您的账号" : "请输入8-12位密码"
        return .init(string: str, attributes: UITextField.placeHolderAttributes)
    }
    
    var keyboardType: UIKeyboardType {
        if id == .account {
            return .asciiCapableNumberPad
        } else {
            return .default
        }
    }
}
