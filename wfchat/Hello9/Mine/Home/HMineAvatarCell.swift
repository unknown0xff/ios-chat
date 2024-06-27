//
//  HMineAvatarCell.swift
//  hello9
//
//  Created by Ada on 5/29/24.
//  Copyright © 2024 hello9. All rights reserved.
//


import UIKit
import SDWebImage

class HMineAvatarCell: HBasicCollectionViewCell<HUserInfoModel> {
    private let kAvatarHeight = 102.0
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .system24.bold
        label.textColor = Colors.themeBlack
        return label
    }()
    
    private lazy var userIdLabel: UILabel = {
        let label = UILabel()
        label.font = .system16
        label.textColor = Colors.themeGray3
        return label
    }()
    
    private lazy var avatar: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = Colors.themeBlue2
        view.layer.masksToBounds = true
        view.layer.borderWidth = 2
        view.layer.borderColor = Colors.white.cgColor
        view.layer.cornerRadius = kAvatarHeight / 2.0
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        selectedBackgroundColor = .clear
        unselectedBackgroundColor = .clear
        contentView.addSubview(avatar)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userIdLabel)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        avatar.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.width.height.equalTo(kAvatarHeight)
            make.centerX.equalToSuperview()
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatar.snp.bottom).offset(16)
            make.height.equalTo(38)
            make.centerX.equalToSuperview()
        }
        
        userIdLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(3)
            make.height.equalTo(26)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-16)
        }
    }
    
    override func bindData(_ data: HUserInfoModel?) {
        userNameLabel.text = data?.displayName
        userIdLabel.text = "账号：\(data?.name ?? "")"
        avatar.sd_setImage(with: data?.portrait, placeholderImage: Images.icon_logo, context: nil)
    }
}
