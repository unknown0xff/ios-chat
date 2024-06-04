//
//  HFriendAddContentCell.swift
//  hello9
//
//  Created by Ada on 6/4/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import UIKit

class HFriendAddContentCell: HBasicTableViewCell<HFriendAddContentModel> {
    
    private lazy var backgroundImageView: UIImageView = {
        let image = UIImageView(image: Images.icon_background)
        return image
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .system28.bold
        label.textColor = Colors.gray03
        label.textAlignment = .center
        return label
    }()
    
    private lazy var userIdLabel: UILabel = {
        let label = UILabel()
        label.font = .system12
        label.textColor = Colors.gray03
        label.textAlignment = .center
        return label
    }()
    
    private lazy var signLabel: UILabel = {
        let label = UILabel()
        label.font = .system12
        label.textColor = Colors.gray06
        label.textAlignment = .center
        return label
    }()
    
    private lazy var avatar: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 45
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = Colors.yellow01
        return imageView
    }()
    
    
    private(set) lazy var addFriendButton: UIButton = {
        let btn = buttonWithImage(Images.icon_more_dot)
        return btn
    }()
    
    private func buttonWithImage(_ image: UIImage) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle("添加好友", for: .normal)
        btn.setTitleColor(Colors.white, for: .normal)
        btn.titleLabel?.font = .system14
        btn.backgroundColor = Colors.blue01
        btn.layer.cornerRadius = 36
        return btn
    }
    
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
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(avatar)
        contentView.addSubview(nameLabel)
        contentView.addSubview(userIdLabel)
        contentView.addSubview(signLabel)
        
        contentView.addSubview(chatButton)
        contentView.addSubview(addFriendButton)
    }
    
    private func makeConstraints() {
        
        backgroundImageView.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(UIScreen.height.multipliedBy(0.263))
        }
        
        avatar.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.width.equalTo(90)
            make.centerY.equalTo(backgroundImageView)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(24)
            make.right.equalTo(-24)
            make.top.equalTo(backgroundImageView.snp.bottom).offset(14)
            make.height.equalTo(42)
        }
        
        userIdLabel.snp.makeConstraints { make in
            make.left.right.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.height.equalTo(16)
        }
        
        signLabel.snp.makeConstraints { make in
            make.left.right.equalTo(nameLabel)
            make.top.equalTo(userIdLabel.snp.bottom).offset(16)
            make.height.equalTo(16)
        }
        
        addFriendButton.snp.makeConstraints { make in
            make.left.equalTo(48)
            make.right.equalTo(-48)
            make.height.equalTo(72)
            make.top.equalTo(signLabel.snp.bottom).offset(36)
            make.bottom.equalTo(-8)
        }
    }
    
    override func bindData(_ data: HFriendAddContentModel?) {
        guard let data else {
            return
        }
        nameLabel.text = data.friendInfo.title
        avatar.sd_setImage(with: data.friendInfo.portrait, placeholderImage: Images.icon_logo)
        userIdLabel.text = "hello号：\(data.friendInfo.userId)"
        signLabel.text = data.friendInfo.social
        
        let title = data.isFriend ? "添加好友" : "发消息"
        addFriendButton.setTitle(title, for: .normal)
    }
}

