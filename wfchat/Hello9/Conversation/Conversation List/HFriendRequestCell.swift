//
//  HFriendRequestCell.swift
//  hello9
//
//  Created by Ada on 6/4/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import UIKit

class HFriendRequestCell: HBasicTableViewCell<[WFCCFriendRequest]> {
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .system17.bold
        label.textColor = Colors.themeBlack
        return label
    }()
    
    private lazy var lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .system14
        label.textColor = Colors.themeGray3
        return label
    }()
    
    private lazy var lastTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .system13
        label.textColor = Colors.themeGray3
        return label
    }()
    
    private lazy var rightContentView: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.alignment = .fill
        s.distribution = .fill
        s.spacing = 6
        return s
    }()
    
    private lazy var topStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.alignment = .fill
        s.distribution = .fill
        s.spacing = 8
        return s
    }()
    
    private lazy var rightBottomIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    
    private lazy var lastMessageIcon: UIImageView = {
        let imageView = UIImageView(image: nil)
        imageView.contentMode = .center
        return imageView
    }()
    
    private lazy var bottomStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.alignment = .fill
        s.distribution = .fill
        s.spacing = 8
        return s
    }()
    
    private lazy var unreadLabel = HUnreadView()
    
    private lazy var avatar: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        contentView.addSubview(avatar)
        contentView.addSubview(unreadLabel)
        
        topStack.addArrangedSubview(userNameLabel)
        
        let spaceView = UIView()
        spaceView.translatesAutoresizingMaskIntoConstraints = false
        spaceView.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        topStack.addArrangedSubview(spaceView)
        
        topStack.addArrangedSubview(lastTimeLabel)
        
        bottomStack.addArrangedSubview(lastMessageIcon)
        bottomStack.addArrangedSubview(lastMessageLabel)
        bottomStack.addArrangedSubview(rightBottomIcon)
        
        contentView.addSubview(topStack)
        contentView.addSubview(bottomStack)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        avatar.snp.makeConstraints { make in
            make.height.width.equalTo(48)
            make.centerY.equalToSuperview()
            make.left.equalTo(16)
        }
        
        userNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        lastTimeLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        lastTimeLabel.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
        lastMessageLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        topStack.snp.makeConstraints { make in
            make.left.equalTo(avatar.snp.right).offset(13)
            make.top.equalTo(avatar)
            make.right.equalTo(-16)
            make.height.equalTo(27)
        }
        
        rightBottomIcon.snp.makeConstraints { make in
            make.width.equalTo(24)
        }
        
        lastMessageIcon.snp.makeConstraints { make in
            make.width.equalTo(20)
        }
        
        bottomStack.snp.makeConstraints { make in
            make.right.left.equalTo(topStack)
            make.bottom.equalTo(avatar)
            make.height.equalTo(22)
        }
        
        unreadLabel.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(16)
            make.width.lessThanOrEqualTo(40)
            make.top.equalTo(avatar)
            make.left.equalTo(avatar.snp.right).offset(-15)
        }
    }
    
    
    override func bindData(_ data: [WFCCFriendRequest]?) {
        guard let data else {
            return
        }
        
        lastMessageIcon.isHidden = true
        rightBottomIcon.isHidden = true
        
        let timestamp = data.max { $0.timestamp < $1.timestamp }?.timestamp
        let unread = data.reduce(into: 0) { partialResult, request in
            if request.readStatus == 0 {
                partialResult += 1
            }
        }
        
        if unread == 0 {
            unreadLabel.isHidden = true
        } else {
            unreadLabel.isHidden = false
            unreadLabel.style = .red
            unreadLabel.unreadCount = Int32(unread)
        }

        if let timestamp {
            lastTimeLabel.text = WFCUUtilities.formatTimeLabel(timestamp)
        } else {
            lastTimeLabel.text = ""
        }
        
        avatar.image = Images.icon_logo
        userNameLabel.text = "系统通知"
        lastMessageLabel.text = "请求添加你为好友"
        
    }
}

