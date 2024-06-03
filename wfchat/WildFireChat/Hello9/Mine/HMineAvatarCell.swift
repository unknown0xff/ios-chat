//
//  HMineAvatarCell.swift
//  hello9
//
//  Created by Ada on 5/29/24.
//  Copyright © 2024 hello9. All rights reserved.
//


import UIKit
import SDWebImage

class HMineAvatarCell: HBasicTableViewCell<HUserInfoModel> {
    private let kAvatarHeight = 112.0
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .system27.bold
        label.textColor = Colors.gray03
        return label
    }()
    
    private lazy var userIdLabel: UILabel = {
        let label = UILabel()
        label.font = .system14.medium
        label.textColor = Colors.gray04.withAlphaComponent(0.5)
        return label
    }()
    
    private lazy var avatar: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = kAvatarHeight / 2.0
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = Colors.gray02
        return imageView
    }()
    
    private lazy var editButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(Images.icon_edit.withRenderingMode(.alwaysOriginal), for: .normal)
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
        contentView.addSubview(avatar)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userIdLabel)
        contentView.addSubview(editButton)
    }
    
    private func makeConstraints() {
        
        avatar.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.width.height.equalTo(kAvatarHeight)
            make.centerX.equalToSuperview()
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatar.snp.bottom).offset(12)
            make.height.equalTo(41)
            make.centerX.equalToSuperview()
        }
        
        userIdLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom)
            make.height.equalTo(21)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-28)
        }
        
        editButton.snp.makeConstraints { make in
            make.width.equalTo(72)
            make.top.equalTo(20)
            make.right.equalTo(-18)
            make.height.equalTo(24)
        }
    }
    
    override func bindData(_ data: HUserInfoModel?) {
        userNameLabel.text = data?.displayName
        userIdLabel.text = data?.userId
        avatar.sd_setImage(with: data?.portrait, placeholderImage: Images.icon_logo, context: nil)
    }
}
