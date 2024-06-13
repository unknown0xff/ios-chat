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
        let btn = UIButton.capsuleButton(title: "同意")
        btn.addTarget(self, action: #selector(didClickActionButton(_:)), for: .touchUpInside)
        return btn
    }()
    let userInfo: HUserInfoModel
    
    init(targetId: String) {
        let userInfo = WFCCIMService.sharedWFCIM().getUserInfo(targetId, refresh: false) ?? .init()
        self.userInfo = .init(info: userInfo)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSubviews()
        makeConstraints()
        
        bindData()
    }
    
    func bindData() {
        avatar.sd_setImage(with: userInfo.portrait, placeholderImage: Images.icon_logo)
        userNameLabel.text = userInfo.displayName
        idLabel.text = userInfo.name.insert(string: "·")
        signLabel.text = userInfo.social.isEmpty ? "昨天是一段历史，明天是一个谜团，今天是天赐的礼物" : userInfo.social
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
        agreeFriendRequest()
    }
    
    func agreeFriendRequest() {
        let hud = HToast.show(on: view, text: "加载中...")
        WFCCIMService.sharedWFCIM().handleFriendRequest(userInfo.userId, accept: true, extra: nil) { [weak self] in
            hud.hide(animated: true)
            guard let self else { return }
            HToast.showAutoHidden(on: self.view, text: "添加成功")
        } error: { code in
            hud.hide(animated: true)
            if code == 19 {
                HToast.showAutoHidden(on: self.view, text: "已过期")
            } else {
                HToast.showAutoHidden(on: self.view, text: "添加失败")
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
