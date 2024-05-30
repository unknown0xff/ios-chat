//
//  HChatListCell.swift
//  hello9
//
//  Created by Ada on 5/30/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import Foundation
import UIKit

class HChatListCell: HBasicTableViewCell<HChatListCellModel> {
    
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
    
    private func configureSubviews() {
        contentView.addSubview(avatar)
        
        topStack.addArrangedSubview(userNameLabel)
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
    }
    
    override func bindData(_ data: HChatListCellModel?) {
        guard let data else {
            return
        }
        NotificationCenter.default.removeObserver(self)
        
        let conversation = data.conversationInfo.conversation!
        switch conversation.type {
        case .Single_Type:
            let userInfo = WFCCIMService.sharedWFCIM().getUserInfo(conversation.target, refresh: false) ?? WFCCUserInfo.init()
            if userInfo.userId.isEmpty {
                userInfo.userId = conversation.target
            }
            updateUserInfo(userInfo)
        case .Group_Type:
            if let groupInfo = WFCCIMService.sharedWFCIM().getGroupInfo(conversation.target, refresh: false) {
                if groupInfo.target.isEmpty {
                    groupInfo.target = conversation.target
                }
                updateGroupInfo(groupInfo)
            }
        case .Chatroom_Type:
            break
        case .Channel_Type:
            if let channelInfo = WFCCIMService.sharedWFCIM().getChannelInfo(conversation.target, refresh: false) {
                if channelInfo.channelId.isEmpty {
                    channelInfo.channelId = conversation.target
                }
                updateChannelInfo(channelInfo)
            }
        case .SecretChat_Type:
            let secretInfo = WFCCIMService.sharedWFCIM().getSecretChatInfo(conversation.target)
            let userId = secretInfo?.userId
            if let userInfo = WFCCIMService.sharedWFCIM().getUserInfo(userId, refresh: false) {
                updateUserInfo(userInfo)
            }
        case .Things_Type:
            userNameLabel.text = "聊天室"
        @unknown default:
            userNameLabel.text = "聊天室"
        }
        
        // TODO: xianda.yang
        lastMessageLabel.text = "Todo"
    }
    
    func updateChannelInfo(_ channelInfo: WFCCChannelInfo) {
        NotificationCenter.default.addObserver(self, selector: #selector(onChannelInfoUpdated(_:)), name: .init(kChannelInfoUpdated), object: nil)
        avatar.sd_setImage(with: URL(string: channelInfo.portrait.urlEncode), placeholderImage: Images.icon_logo)
        if channelInfo.name.isEmpty {
            userNameLabel.text = "频道"
        } else {
            userNameLabel.text = channelInfo.name
        }
    }
    
    func updateUserInfo(_ userInfo: WFCCUserInfo) {
        NotificationCenter.default.addObserver(self, selector: #selector(onUserInfoUpdated(_:)), name: .init(kUserInfoUpdated), object: nil)
        
        avatar.sd_setImage(with: URL(string: userInfo.portrait.urlEncode), placeholderImage: Images.icon_logo)
        if !userInfo.friendAlias.isEmpty {
            userNameLabel.text = userInfo.friendAlias
        } else if !userInfo.displayName.isEmpty {
            userNameLabel.text = userInfo.displayName
        } else {
            let target = cellData?.conversationInfo.conversation.target ?? ""
            userNameLabel.text = "user<\(target)>"
        }
    }
    
    
    func updateGroupInfo(_ groupInfo: WFCCGroupInfo) {
        
        let kGroupPortraitChangedNotificationName = Notification.Name("GroupPortraitChanged")
        NotificationCenter.default.removeObserver(self, name: kGroupPortraitChangedNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onGroupInfoUpdated(_:)), name: .init(kGroupInfoUpdated), object: nil)
        
        if groupInfo.type == .GroupType_Organization {
            if !groupInfo.portrait.isEmpty {
                avatar.sd_setImage(with: URL(string: groupInfo.portrait.urlEncode), placeholderImage: Images.icon_logo)
            } else {
                avatar.image = Images.icon_logo
            }
        } else {
            if !groupInfo.portrait.isEmpty {
                avatar.sd_setImage(with: URL(string: groupInfo.portrait.urlEncode), placeholderImage: Images.icon_logo)
            } else {
                let groupId = groupInfo.target
                
                let isGroupType = cellData?.conversationInfo.conversation.type == .Group_Type
                let isSameGroupId = cellData?.conversationInfo.conversation.target == groupId
                
                NotificationCenter.default.addObserver(forName: kGroupPortraitChangedNotificationName, object: nil, queue: OperationQueue.main) { [weak self] note in
                    let path = (note.userInfo?["path"] as? String) ?? ""
                    let noteObject = note.object as? String
                    if groupId == noteObject, isGroupType, isSameGroupId {
                        self?.avatar.sd_setImage(with: URL(fileURLWithPath: path), placeholderImage: Images.icon_logo)
                    }
                }
                
                let path = WFCCUtilities.getGroupGridPortrait(groupId, width: 80, generateIfNotExist: true) { userId in
                    return Images.icon_logo
                }
                if let path {
                    avatar.sd_setImage(with: URL(fileURLWithPath: path), placeholderImage: Images.icon_logo)
                } else {
                    avatar.image = Images.icon_logo
                }
            }
        }
        
        if !groupInfo.displayName.isEmpty {
            userNameLabel.text = groupInfo.displayName
        } else {
            userNameLabel.text = "群聊"
        }
    }
    
    @objc func onChannelInfoUpdated(_ sender: Notification) {
        guard let channelInfoList = sender.userInfo?["channelInfoList"] as? Array<WFCCChannelInfo>,
              let conv = cellData?.conversationInfo,
                conv.conversation.type == .Channel_Type
        else {
            return
        }
        for channelInfo in channelInfoList {
            if channelInfo.channelId == conv.conversation.target {
                bindData(cellData)
                break
            }
        }
    }
    
    @objc func onGroupInfoUpdated(_ sender: Notification) {
        guard let groupInfoList = sender.userInfo?["groupInfoList"] as? Array<WFCCGroupInfo>,
              let conv = cellData?.conversationInfo,
                conv.conversation.type == .Group_Type
        else {
            return
        }
        for groupInfo in groupInfoList {
            if groupInfo.target == conv.conversation.target {
                bindData(cellData)
                break
            }
        }
    }
    
    @objc func onUserInfoUpdated(_ sender: Notification) {
        guard let userInfoList = sender.userInfo?["userInfoList"] as? Array<WFCCUserInfo>,
              let conv = cellData?.conversationInfo else {
            return
        }
        for userInfo in userInfoList {
            if conv.conversation.type == .Single_Type ||
                conv.conversation.type == .SecretChat_Type {
                if userInfo.userId == conv.conversation.target {
                    bindData(cellData)
                    break
                }
            }
            
            if conv.lastMessage.fromUser == userInfo.userId {
                bindData(cellData)
                break
            }
        }
    }
}

