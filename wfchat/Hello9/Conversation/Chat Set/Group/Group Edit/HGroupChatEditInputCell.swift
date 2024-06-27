//
//  HGroupChatEditInputCell.swift
//  Hello9
//
//  Created by Ada on 2024/6/27.
//  Copyright © 2024 Hello9. All rights reserved.
//

import Foundation

class HGroupChatEditInputCell: HBasicCollectionViewCell<HGroupChatEditModel> {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system14
        label.textColor = Colors.themeGray2
        return label
    }()
    
    private(set) lazy var textField: HTextField = {
        let tf = HTextField.default
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
        
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalTo(16)
            make.height.equalTo(26)
        }
        
        textField.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.right.equalTo(-16)
            make.height.equalTo(26)
            make.bottom.equalTo(-12)
        }
    }
    
    override func bindData(_ data: HGroupChatEditModel?) {
        guard let data else {
            return
        }
        textField.placeholder = data.category == .name ? "请输入群名称" : "请输入群简介"
        titleLabel.text = data.title
        textField.text = data.value
        textField.returnKeyType = data.category == .name ? .next : .done
    }
}
