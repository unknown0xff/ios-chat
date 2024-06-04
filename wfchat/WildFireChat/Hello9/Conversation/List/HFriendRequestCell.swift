//
//  HFriendRequestCell.swift
//  hello9
//
//  Created by Ada on 6/4/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import UIKit

class HFriendRequestCell: HBasicTableViewCell<WFCCFriendRequest> {
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .system14.bold
        label.textColor = Colors.gray03
        return label
    }()
    
    private lazy var lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .system14
        label.textColor = Colors.gray03
        return label
    }()
    
    private lazy var lastTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .system12
        label.textColor = Colors.gray04.withAlphaComponent(0.5)
        return label
    }()
    
    private lazy var unreadLabel: UILabel = {
        let label = UILabel()
        label.font = .system13.bold
        label.textColor = Colors.white
        label.backgroundColor = Colors.red01
        label.layer.cornerRadius = 9
        label.layer.masksToBounds = true
        label.textAlignment = .center
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
    
    private lazy var bottomStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.alignment = .fill
        s.distribution = .fill
        s.spacing = 8
        return s
    }()
    
    private lazy var avatar: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 32
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureSubviews() {
        contentView.addSubview(avatar)
        
        topStack.addArrangedSubview(userNameLabel)
        
        let spaceView = UIView()
        spaceView.translatesAutoresizingMaskIntoConstraints = false
        spaceView.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        topStack.addArrangedSubview(spaceView)
        
        topStack.addArrangedSubview(lastTimeLabel)
        
        bottomStack.addArrangedSubview(lastMessageLabel)
        bottomStack.addArrangedSubview(unreadLabel)
        
        rightContentView.addArrangedSubview(topStack)
        rightContentView.addArrangedSubview(bottomStack)
        
        contentView.addSubview(rightContentView)
    }
    
    private func makeConstraints() {
        
        avatar.snp.makeConstraints { make in
            make.height.width.equalTo(64)
            make.top.equalTo(16)
            make.bottom.equalTo(-16)
            make.left.equalTo(26)
        }
        
        userNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        lastTimeLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        lastMessageLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        unreadLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        rightContentView.snp.makeConstraints { make in
            make.left.equalTo(avatar.snp.right).offset(16)
            make.centerY.equalTo(avatar)
            make.right.equalTo(-26)
        }
        
        unreadLabel.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(18)
        }
        
    }
    
    override func bindData(_ data: WFCCFriendRequest?) {
        guard let data else {
            return
        }
        
        if data.readStatus == 0 {
            unreadLabel.text = "1"
            unreadLabel.isHidden = false
        } else {
            unreadLabel.isHidden = true
        }
        
        lastTimeLabel.text = WFCUUtilities.formatTimeLabel(data.timestamp)
        
        if let userInfo = WFCCIMService.sharedWFCIM().getUserInfo(data.target ?? "", refresh: false) {
            avatar.sd_setImage(with: .init(string: userInfo.portrait ?? .init()), placeholderImage: Images.icon_logo)
            userNameLabel.text = userInfo.displayName ?? ""
        }
        lastMessageLabel.text = data.reason
        
    }
}

