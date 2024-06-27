//
//  HGroupMemberCell.swift
//  Hello9
//
//  Created by Ada on 6/13/24.
//  Copyright © 2024 Hello9. All rights reserved.
//

import UIKit

class HGroupMemberCell: HBasicTableViewCell<WFCCGroupMember> {
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .system14.bold
        label.textColor = Colors.themeBlack
        return label
    }()
    
    private lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.font = .system12
        label.textColor = Colors.themeGray3
        return label
    }()
    
    private lazy var avatar: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = Colors.themeGray4Background
        return imageView
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        contentView.addSubview(avatar)
        contentView.addSubview(nameLabel)
        contentView.addSubview(typeLabel)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        avatar.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(12)
            make.width.height.equalTo(40)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatar.snp.right).offset(12)
            make.right.equalTo(-44)
            make.centerY.equalToSuperview()
        }
        
        typeLabel.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
        }
    }
    
    override func bindData(_ data: WFCCGroupMember?) {
        
        guard let data else {
            // 添加
            avatar.image = Images.icon_add
            nameLabel.text = "邀请新成员"
            typeLabel.text = ""
            avatar.contentMode = .center
            return
        }
        
        avatar.contentMode = .scaleAspectFit
        let userInfo = WFCCIMService.sharedWFCIM().getUserInfo(data.memberId, inGroup: data.groupId, refresh: false) ?? .init()
        let userInfoModel = HUserInfoModel(info: userInfo)
        
        nameLabel.text = userInfoModel.title
        avatar.sd_setImage(with: userInfoModel.portrait, placeholderImage: Images.icon_logo)
        
        if data.type == .Member_Type_Owner {
            typeLabel.text = "创建者"
        } else if data.type == .Member_Type_Manager {
            typeLabel.text = "管理者"
        } else {
            typeLabel.text = ""
        }
    }
}

