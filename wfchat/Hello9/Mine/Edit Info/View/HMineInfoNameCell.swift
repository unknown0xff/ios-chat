//
//  HMineInfoNameCell.swift
//  Hello9
//
//  Created by Ada on 2024/6/20.
//  Copyright © 2024 Hello9. All rights reserved.
//

import Foundation

class HMineInfoNameCell: HBasicCollectionViewCell<String> {
    
    private lazy var textField: UITextField = {
        let tf = UITextField.default
        tf.textColor = Colors.themeBlack
        tf.font = .system16
        return tf
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        selectedBackgroundColor = .white
        contentView.addSubview(textField)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        textField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
            make.height.equalTo(58)
        }
    }
    
    override func bindData(_ data: String?) {
        textField.placeholder = indexPath.item == 0 ? "名字" : "姓氏"
        textField.text = data
    }
}

class HMineInfoSocialCell: HBasicCollectionViewCell<String> {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system16
        label.textColor = Colors.themeButtonDisable
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .system16.medium
        label.textColor = Colors.themeBlack
        return label
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        selectedBackgroundColor = .white
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        titleLabel.snp.makeConstraints { make in
            make.left.top.equalTo(16)
            make.height.equalTo(26)
            make.bottom.equalTo(-16)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
        }
    }
    
    override func bindData(_ data: String?) {
        titleLabel.text = indexPath.item == 0 ? "号码" : "邮箱"
        subTitleLabel.text = data
    }
}

class HMineInfoDescCell: HBasicCollectionViewCell<String> {
    
    private(set) lazy var textView: UITextView = {
        let tv = UITextView()
        tv.textColor = Colors.themeBlack
        tv.font = .system16
        tv.showsHorizontalScrollIndicator = false
        tv.showsVerticalScrollIndicator = false
        return tv
    }()
    
    private lazy var textField: UITextField = {
        let tf = UITextField.default
        return tf
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        selectedBackgroundColor = .white
        contentView.addSubview(textView)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
            make.height.equalTo(26)
        }
    }
    
    override func bindData(_ data: String?) {
        textView.text = data
    }
}
