//
//  HMineInfoSocialCell.swift
//  Hello9
//
//  Created by Ada on 2024/6/27.
//  Copyright © 2024 Hello9. All rights reserved.
//
//  社交信息输入 号码&邮箱等
//

import Foundation

class HMineInfoSocialCell: HBasicCollectionViewCell<String> {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system16
        label.textColor = Colors.themeButtonDisable
        return label
    }()
    
    private(set) lazy var textField: HTextField = {
        let tf = HTextField.default
        tf.textAlignment = .right
        return tf
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        selectedBackgroundColor = .white
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLabel.snp.makeConstraints { make in
            make.left.top.equalTo(16)
            make.height.equalTo(26)
            make.bottom.equalTo(-16)
        }
        
        textField.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.left.equalTo(titleLabel.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
    }
    
    override func bindData(_ data: String?) {
        titleLabel.text = indexPath.item == 0 ? "号码" : "邮箱"
        textField.indexPath = indexPath
        textField.text = data
        textField.placeholder = indexPath.item == 0 ? "请输入号码" : "请输入邮箱"
        textField.keyboardType = indexPath.item == 0 ? .phonePad : .emailAddress
        textField.returnKeyType = indexPath.item == 0 ? .next : .done
    }
}

