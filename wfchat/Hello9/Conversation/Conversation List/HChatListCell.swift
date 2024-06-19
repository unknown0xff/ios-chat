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
        label.font = .system17.bold
        label.textColor = Colors.themeBlack
        return label
    }()
    
    private lazy var secretTag: UILabel = {
        let label = UILabel()
        label.font = .system9
        label.text = "【密聊】"
        label.textColor = Colors.themeBlue1
        label.textAlignment = .center
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
        topStack.addArrangedSubview(secretTag)
        
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
    
    override func bindData(_ data: HChatListCellModel?) {
        guard let data else {
            return
        }
        
        NotificationCenter.default.removeObserver(self)
        
        let unreadCount = data.conversationInfo.unreadCount
        let unread = unreadCount?.unread ?? 0
        let isSilent = data.conversationInfo.isSilent
        let lastMessage = data.conversationInfo.lastMessage
        
        if unread == 0 {
            unreadLabel.isHidden = true
        } else {
            unreadLabel.isHidden = false
           
            if isSilent {
                unreadLabel.style = .gray
            } else {
                unreadLabel.style = .red
            }
            unreadLabel.unreadCount = unread
        }

        let conversation = data.conversationInfo.conversation ?? .init()
        let isTop = data.conversationInfo.isTop == 1
        contentView.backgroundColor = isTop ? Colors.themeGray4Background : Colors.white
        
        // 优先级： 1、@ 消息提醒, 2、声音, 3、置顶,  4、密聊
        let unreadMentionAll = unreadCount?.unreadMentionAll ?? 0
        let unreadMention = unreadCount?.unreadMention ?? 0
        // 是否有人@
        if lastMessage?.direction == .MessageDirection_Receive,
           conversation.type == .Group_Type,
           unreadMentionAll + unreadMention > 0 {
            rightBottomIcon.image = Images.icon_at
            rightBottomIcon.isHidden = false
        } else if isSilent {
            rightBottomIcon.image = Images.icon_mute_gray
            rightBottomIcon.isHidden = false
        } else if isTop {
            rightBottomIcon.image = Images.icon_top_gray
            rightBottomIcon.isHidden = false
        } else if conversation.type == .SecretChat_Type {
            rightBottomIcon.image = Images.icon_lock
            rightBottomIcon.isHidden = false
        } else {
            rightBottomIcon.isHidden = true
        }
        
        switch conversation.type {
        case .Single_Type:
            let userInfo = WFCCIMService.sharedWFCIM().getUserInfo(conversation.target, refresh: false) ?? WFCCUserInfo.init()
            let userId = userInfo.userId ?? ""
            if userId.isEmpty {
                userInfo.userId = conversation.target
            }
            updateUserInfo(userInfo)
        case .Group_Type:
            if let groupInfo = WFCCIMService.sharedWFCIM().getGroupInfo(conversation.target, refresh: false) {
                let target = groupInfo.target ?? ""
                if target.isEmpty {
                    groupInfo.target = conversation.target
                }
                updateGroupInfo(groupInfo)
            }
        case .Chatroom_Type:
            break
        case .Channel_Type:
            if let channelInfo = WFCCIMService.sharedWFCIM().getChannelInfo(conversation.target, refresh: false) {
                let channelId = channelInfo.channelId ?? ""
                if channelId.isEmpty {
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
        
        secretTag.isHidden = conversation.type != .SecretChat_Type
        
        lastTimeLabel.isHidden = false
        lastTimeLabel.text = WFCUUtilities.formatTimeLabel(data.conversationInfo.timestamp)
        
        if let lastMessage {
            lastMessageIcon.isHidden = false
            if let _ = lastMessage.content as? WFCCSoundMessageContent {
                lastMessageIcon.image = Images.icon_voice
                lastMessageLabel.text = "一条语音留言"
            } else if let _ = lastMessage.content as? WFCCVideoMessageContent {
                lastMessageIcon.image = Images.icon_video
                lastMessageLabel.text = "视频留言"
            } else if let location = lastMessage.content as? WFCCLocationMessageContent {
                lastMessageIcon.image = Images.icon_location
                lastMessageLabel.text = location.title ?? ""
            } else if let _ = lastMessage.content as? WFCCImageMessageContent {
                lastMessageIcon.image = Images.icon_link
                lastMessageLabel.text = "图片"
            } else if let file = lastMessage.content as? WFCCFileMessageContent {
                lastMessageIcon.image = Images.icon_link
                lastMessageLabel.text = file.name
            } else {
                lastMessageIcon.isHidden = true
                lastMessageLabel.text = lastMessage.digest() ?? ""
            }
        } else {
            lastMessageIcon.isHidden = true
            lastMessageLabel.text = ""
        }
    }
    
    func updateChannelInfo(_ channelInfo: WFCCChannelInfo) {
        NotificationCenter.default.addObserver(self, selector: #selector(onChannelInfoUpdated(_:)), name: .init(kChannelInfoUpdated), object: nil)
        avatar.sd_setImage(with: URL(string: channelInfo.portrait ?? ""), placeholderImage: Images.icon_logo)
        let channelName = channelInfo.name ?? ""
        if channelName.isEmpty {
            userNameLabel.text = "频道"
        } else {
            userNameLabel.text = channelName
        }
    }
    
    func updateUserInfo(_ userInfo: WFCCUserInfo) {
        NotificationCenter.default.addObserver(self, selector: #selector(onUserInfoUpdated(_:)), name: .init(kUserInfoUpdated), object: nil)
        avatar.sd_setImage(with: URL(string: (userInfo.portrait ?? "")), placeholderImage: userInfo.portraitPlaceholder)
        let friendAlias = userInfo.friendAlias ?? ""
        let displayName = userInfo.displayName ?? ""
        if !friendAlias.isEmpty {
            userNameLabel.text = userInfo.friendAlias
        } else if !displayName.isEmpty {
            userNameLabel.text = displayName
        } else {
            let target = cellData?.conversationInfo.conversation?.target ?? ""
            userNameLabel.text = "user<\(target)>"
        }
    }
    
    func updateGroupInfo(_ groupInfo: WFCCGroupInfo) {
        
        let kGroupPortraitChangedNotificationName = Notification.Name("GroupPortraitChanged")
        NotificationCenter.default.removeObserver(self, name: kGroupPortraitChangedNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onGroupInfoUpdated(_:)), name: .init(kGroupInfoUpdated), object: nil)
        
        if groupInfo.type == .GroupType_Organization {
            if !groupInfo.portrait.isEmpty {
                avatar.sd_setImage(with: URL(string: groupInfo.portrait ?? ""), placeholderImage: groupInfo.portraitPlaceholder)
            } else {
                avatar.image = Images.icon_logo
            }
        } else {
            if !groupInfo.portrait.isEmpty, let url = URL(string: groupInfo.portrait ?? "") {
                avatar.sd_setImage(with: url, placeholderImage: groupInfo.portraitPlaceholder)
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
            let fromUser = conv.lastMessage?.fromUser ?? ""
            if fromUser == userInfo.userId {
                bindData(cellData)
                break
            }
        }
    }
}

import SDWebImage

private extension WFCCUserInfo {
    var portraitUrl: URL? {
        return URL(string: portrait ?? "")
    }
    
    var portraitPlaceholder: UIImage {
        SDImageCache.shared.imageFromCache(forKey: portraitUrl?.absoluteString ?? "") ?? Images.icon_logo
    }
}

private extension WFCCGroupInfo {
    
    var portraitUrl: URL? {
        return URL(string: portrait ?? "")
    }
    
    var portraitPlaceholder: UIImage {
        SDImageCache.shared.imageFromCache(forKey: portraitUrl?.absoluteString ?? "") ?? Images.icon_logo
    }
}
