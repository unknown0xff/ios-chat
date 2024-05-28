//
//  HLoginInputCell.swift
//  ios-hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import UIKit

class HLoginInputCell: UITableViewCell {

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system12
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
        return field
    }()
    
    private lazy var leftIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var rightButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(Images.icon_refresh, for: .normal)
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
        
        stack.addArrangedSubview(leftIcon)
        stack.setCustomSpacing(16, after: leftIcon)
        stack.addArrangedSubview(textField)
        stack.addArrangedSubview(rightButton)
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
            make.left.equalTo(20)
            make.width.equalTo(24)
            make.height.equalToSuperview()
        }
        
        rightButton.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalToSuperview()
        }
    }
    
    func bind(_ model: HLoginModel) {
        leftIcon.image = model.leftImage
        
        textField.text = model.value
        titleLabel.text = model.title
        
        rightButton.isHidden = model.id == .password
    }
    
}

fileprivate extension HLoginModel {
    
    var leftImage: UIImage {
        id == .account ? Images.icon_refresh : Images.icon_password
    }
    
}
