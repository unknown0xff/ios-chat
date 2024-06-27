//
//  HNewFriendDetailViewController.swift
//  Hello9
//
//  Created by Ada on 6/12/24.
//  Copyright © 2024 Hello9. All rights reserved.
//

import UIKit
import Combine

class HNewFriendDetailViewController: HBaseViewController {
    
    private lazy var contentView: UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceVertical = true
        return view
    }()
    
    private lazy var avatar: UIImageView = {
        let view = UIImageView()
        view.layer.masksToBounds = true
        view.layer.borderWidth = 2
        view.layer.borderColor = Colors.white.cgColor
        view.layer.cornerRadius = 51
        return view
    }()
    
    private lazy var userInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.white
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.themeGray4Background
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system14.medium
        label.text = "个人简介"
        label.textColor = Colors.themeBusiness
        return label
    }()
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .system24.bold
        label.textColor = Colors.themeBlack
        return label
    }()
    
    private lazy var idLabel: UILabel = {
        let label = UILabel()
        label.font = .system14.bold
        label.textColor = Colors.themeBusiness
        return label
    }()
    
    private lazy var signLabel: UILabel = {
        let label = UILabel()
        label.font = .system14
        label.numberOfLines = 0
        label.textColor = Colors.themeGray3
        return label
    }()
    
    private lazy var idView: UIStackView = {
        let s = UIStackView()
        s.distribution = .fill
        s.alignment = .center
        s.layer.cornerRadius = 9
        s.layer.masksToBounds = true
        s.layer.borderColor = Colors.themeBusiness.cgColor
        s.layer.borderWidth = 1
        
        s.addArrangedSubview(UIView.space(width: 4))
        let leftIcon = UILabel()
        leftIcon.textColor = Colors.white
        leftIcon.font = .system14.bold
        leftIcon.text = "ID"
        leftIcon.textAlignment = .center
        leftIcon.backgroundColor = Colors.black
        leftIcon.layer.cornerRadius = 6
        leftIcon.layer.masksToBounds = true
        s.addArrangedSubview(leftIcon)
        leftIcon.snp.makeConstraints { make in
            make.width.equalTo(39)
            make.height.equalTo(24)
        }
        s.setCustomSpacing(14, after: leftIcon)
        
        s.addArrangedSubview(idLabel)
        s.setCustomSpacing(13, after: idLabel)
        
        let copyIcon = UIButton(type:.system)
        copyIcon.setImage(Images.icon_copy, for: .normal)
        s.addArrangedSubview(copyIcon)
        copyIcon.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.width.equalTo(40)
        }
        copyIcon.addTarget(self, action: #selector(didClickCopyButton(_:)), for: .touchUpInside)
        return s
    }()
    
    lazy var actionButton: UIButton = {
        let btn = UIButton.capsuleButton(title: "")
        btn.addTarget(self, action: #selector(didClickActionButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    private var userInfo: HUserInfoModel = .init(info: .init())
    private var groupInfo: HGroupInfo = .init(info: .init())
    let isGroup: Bool
    let targetId: String
    let isHandleFriendRequest: Bool
    
    init(targetId: String, isGroup: Bool = false, isHandleFriendRequest: Bool = false) {
        self.targetId = targetId
        self.isGroup = isGroup
        self.isHandleFriendRequest = isHandleFriendRequest
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNotifications()
        loadData()
    }
    
    func loadData() {
        DispatchQueue.main.async {
            if self.isGroup {
                let groupInfo = WFCCIMService.sharedWFCIM().getGroupInfo(self.targetId, refresh: true) ?? .init()
                self.groupInfo = .init(info: groupInfo)
            } else {
                let userInfo = WFCCIMService.sharedWFCIM().getUserInfo(self.targetId, refresh: true) ?? .init()
                self.userInfo = .init(info: userInfo)
            }
            self.bindData()
        }
    }
    
    func bindData() {
        if isGroup {
            avatar.sd_setImage(with: groupInfo.portrait, placeholderImage: Images.icon_logo)
            userNameLabel.text = groupInfo.displayName
            idLabel.text = groupInfo.target.insert(string: "·")
            signLabel.text = groupInfo.desc
            titleLabel.text = "群介绍"
            actionButton.setTitle("申请加群", for: .normal)
        } else {
            avatar.sd_setImage(with: userInfo.portrait, placeholderImage: Images.icon_logo)
            userNameLabel.text = userInfo.displayName
            idLabel.text = userInfo.name.insert(string: "·")
            signLabel.text = userInfo.social.isEmpty ? "昨天是一段历史，明天是一个谜团，今天是天赐的礼物" : userInfo.social
            titleLabel.text = "个人简介"
            
            if userInfo.isFriend {
                actionButton.setTitle("发信息", for: .normal)
            } else {
                if isHandleFriendRequest {
                    actionButton.setTitle("同意", for: .normal)
                } else {
                    actionButton.setTitle("添加好友", for: .normal)
                }
                
            }
        }
    }
    
    func addNotifications() {
        if isGroup {
            NotificationCenter.default.addObserver(forName: .init(kGroupInfoUpdated), object: nil, queue: .main) { [weak self] noti in
                if let groupInfoList = noti.userInfo?["groupInfoList"] as? [WFCCGroupInfo] {
                    let groupInfo = (groupInfoList.first { $0.target == self?.targetId }) ?? .init()
                    self?.groupInfo = .init(info: groupInfo)
                    self?.bindData()
                }
            }
        } else {
            NotificationCenter.default.addObserver(forName: .init(kUserInfoUpdated), object: nil, queue: .main) { [weak self] noti in
                let userInfo = WFCCIMService.sharedWFCIM().getUserInfo(self?.targetId, refresh: false) ?? .init()
                self?.userInfo = .init(info: userInfo)
                self?.bindData()
            }
        }
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        view.addSubview(contentView)
        
        contentView.addSubview(avatar)
        contentView.addSubview(userInfoView)
        contentView.addSubview(actionButton)
        
        userInfoView.addSubview(userNameLabel)
        userInfoView.addSubview(idView)
        userInfoView.addSubview(lineView)
        userInfoView.addSubview(titleLabel)
        userInfoView.addSubview(signLabel)
    }
    
    override func makeConstraints() {
        super.configureSubviews()
        contentView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.width.left.right.bottom.equalToSuperview()
        }
        
        avatar.snp.makeConstraints { make in
            make.top.equalTo(40)
            make.width.height.equalTo(102)
            make.centerX.equalToSuperview()
        }
        
        userInfoView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.width.equalToSuperview().offset(-32)
            make.top.equalTo(avatar.snp.bottom).offset(16)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.width.lessThanOrEqualToSuperview().offset(-32)
            make.top.equalTo(16)
            make.height.equalTo(38)
            make.centerX.equalToSuperview()
        }
        
        idView.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(32)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(idView.snp.bottom).offset(20)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(1)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.height.equalTo(22)
            make.top.equalTo(lineView.snp.bottom).offset(16)
        }
        
        signLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.equalTo(-20)
        }
        
        actionButton.snp.makeConstraints { make in
            make.height.equalTo(54)
            make.left.equalTo(30)
            make.width.equalToSuperview().offset(-60)
            make.top.equalTo(userInfoView.snp.bottom).offset(55)
        }
    }
    
    @objc func didClickCopyButton(_ sender: UIButton) {
        UIPasteboard.general.string = userInfo.name
    }
    
    @objc func didClickActionButton(_ sender: UIButton) {
        
        if isGroup {
            // TODO: xianda.yang
        } else {
            if userInfo.isFriend {
                beginChat()
            } else {
                if isHandleFriendRequest {
                    agreeFriendRequest()
                } else {
                    addFriend()
                }
            }
        }
        
    }
    
    private func beginChat() {
        let conversation = WFCCConversation(type: .Single_Type, target: targetId, line: 0)!
        let mvc = HMessageListViewController()
        mvc.conversation = conversation
        mvc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(mvc, animated: true)
    }
    
    private func addFriend() {
        let hud = HToast.showLoading("发送中...")
        let userInfo = WFCCIMService.sharedWFCIM().getUserInfo(IMUserInfo.userId, refresh: false) ?? .init()
        let reason = "我是\(userInfo.displayName ?? "")"
        
        let extra = ["receiveUserId": targetId]
        let data = try? JSONEncoder().encode(extra)
        let jsonExtra = String(data: data ?? .init(), encoding: .utf8)
        
        WFCCIMService.sharedWFCIM().sendFriendRequest(targetId, reason: reason, extra: jsonExtra)  {
            hud?.hide(animated: true)
        } error: { code in
            hud?.hide(animated: true)
            if(code == 16) {
                HToast.showTipAutoHidden(text: "已经发送过添加好友请求了")
            } else if(code == 18) {
                HToast.showTipAutoHidden(text: "好友请求已被拒绝")
            } else {
                HToast.showTipAutoHidden(text: "发送失败")
            }
        }
    }
    
    private func agreeFriendRequest() {
        let hud = HToast.showLoading("发送中...")
        WFCCIMService.sharedWFCIM().handleFriendRequest(userInfo.userId, accept: true, extra: nil) { [weak self] in
            hud?.hide(animated: true)
            guard let self else { return }
            HToast.showTipAutoHidden(text: "添加成功")
            self.actionButton.setTitle("发信息", for: .normal)
        } error: { code in
            hud?.hide(animated: true)
            if code == 19 {
                HToast.showTipAutoHidden(text: "已过期")
            } else {
                HToast.showTipAutoHidden(text: "添加失败")
            }
        }
    }
}

extension String {
    
    func insert(string: String, every n: Int = 3) -> String {
        var result = ""
        for (index, char) in self.enumerated() {
            if index != 0 && index % n == 0 {
                result.append(string)
            }
            result.append(char)
        }
        return result
    }
    
}
