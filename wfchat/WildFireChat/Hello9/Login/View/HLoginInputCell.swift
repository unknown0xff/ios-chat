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
    func didClickRefreshButton()
}
extension HLoginInputCellDelegate {
    func didClickRefreshButton() {  }
}

class HLoginInputCell: HBasicTableViewCell<HLoginInputModel> {

    weak var delegate: HLoginInputCellDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system12
        label.textColor = Colors.gray03
        return label
    }()
    
    private lazy var stack: UIStackView = {
        let s = UIStackView()
        s.alignment = .center
        s.distribution = .fill
        s.layer.borderColor = Colors.gray02.cgColor
        s.layer.borderWidth = 1.5
        s.layer.cornerRadius = 12
        s.layer.masksToBounds = true
        return s
    }()
    
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.textColor = Colors.black
        field.font = .system16
        return field
    }()
    
    private lazy var leftIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var rightButton: UIButton = {
        let btn = UIButton(type: .custom)
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
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(stack)
        
        let space = UIView()
        stack.addArrangedSubview(space)
        space.snp.makeConstraints { make in
            make.width.equalTo(20)
        }
        
        stack.addArrangedSubview(leftIcon)
        stack.setCustomSpacing(16, after: leftIcon)
        stack.addArrangedSubview(textField)
        stack.addArrangedSubview(rightButton)
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        rightButton.addTarget(self, action: #selector(didClickRightButton(_:)), for: .touchUpInside)
    }
    
    private func makeConstraints() {
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(32)
            make.top.equalTo(8)
            make.height.equalTo(15)
        }
        
        stack.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.left)
            make.right.equalTo(-32)
            make.height.equalTo(64)
            make.bottom.equalTo(-8)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        leftIcon.snp.makeConstraints { make in
            make.width.equalTo(24)
            make.height.equalToSuperview()
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
        textField.placeholder = data.placeholder
        titleLabel.text = data.title
        
        if let image = data.rightImage {
            rightButton.setImage(image, for: .normal)
            rightButton.isHidden = false
        } else {
            rightButton.isHidden = true
        }
        
        textField.keyboardType = data.keyboardType
        textField.isSecureTextEntry = data.isSecureTextEntry
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
        if !data.isNewUser && data.id == .password {
            data.isSecureTextEntry.toggle()
            cellData = data
            delegate?.didChangeInputValue(data, at: indexPath)
            return
        }
        
        startRotation()
        
        DispatchQueue.global().async {
            sleep(2) // TODO: 模拟网络请求等操作
            DispatchQueue.main.async {
                self.stopRotation()
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
            return isNewUser ? "您的hello号是" : "账号"
        case .password:
            return isNewUser ? "您的密码" : "密码"
        }
    }
    
    var leftImage: UIImage {
        id == .account ? Images.icon_account : Images.icon_password
    }
    
    var rightImage: UIImage? {
        switch id {
        case .account:
            return isNewUser ? Images.icon_refresh : nil
        case .password:
            return isNewUser ? nil : Images.icon_password_hidden
        }
    }
    
    var placeholder: String {
        id == .account ? "请输入您的账号" : "请输入您的密码"
    }
    
    var keyboardType: UIKeyboardType {
        if id == .account {
            return .asciiCapableNumberPad
        } else {
            return .default
        }
    }
}
