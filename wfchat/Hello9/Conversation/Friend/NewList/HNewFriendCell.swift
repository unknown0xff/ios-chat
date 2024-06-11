//
//  HNewFriendCell.swift
//  hello9
//
//  Created by Ada on 6/5/24.
//  Copyright © 2024 hello9. All rights reserved.
//


import UIKit

protocol HNewFriendCellDelegate: AnyObject {
    func onAccept(_ request: WFCCFriendRequest, at indexPath: IndexPath)
    func onIgnore(_ request: WFCCFriendRequest, at indexPath: IndexPath)
}

class HNewFriendCell: HBasicCollectionViewCell<WFCCFriendRequest> {
    
    weak var delegate: HNewFriendCellDelegate?
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .system17.bold
        label.textColor = Colors.themeBlack
        return label
    }()
    
    private lazy var lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .system12
        label.textColor = Colors.themeGray3
        return label
    }()
    
    private lazy var avatar: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var rightContent: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.alignment = .fill
        s.distribution = .fill
        s.spacing = 6
        return s
    }()
    
    private lazy var rightActions: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.alignment = .trailing
        s.distribution = .fillEqually
        s.spacing = 6
        return s
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "已同意"
        label.font = .system14
        label.textColor = Colors.gray01
        return label
    }()
    
    private lazy var acceptButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = Colors.themeBlue1
        btn.layer.cornerRadius = 15
        btn.setTitle("同意", for: .normal)
        btn.setTitleColor(Colors.white, for: .normal)
        btn.addTarget(self, action: #selector(didClickAcceptButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var ignoreButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("忽略", for: .normal)
        btn.backgroundColor = Colors.white
        btn.layer.cornerRadius = 15
        btn.setTitleColor(Colors.gray01, for: .normal)
        btn.addTarget(self, action: #selector(didClickIgnoreButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        
        rightContent.addArrangedSubview(userNameLabel)
        rightContent.addArrangedSubview(lastMessageLabel)
        contentView.addSubview(rightContent)
        
        rightActions.addArrangedSubview(acceptButton)
        rightActions.addArrangedSubview(ignoreButton)
        contentView.addSubview(rightActions)
        contentView.addSubview(statusLabel)
    }
    
    private func makeConstraints() {
        
        avatar.snp.makeConstraints { make in
            make.height.width.equalTo(48)
            make.top.equalTo(14)
            make.bottom.equalTo(-14)
            make.left.equalTo(16)
        }
        
        rightContent.snp.makeConstraints { make in
            make.left.equalTo(avatar.snp.right).offset(12)
            make.centerY.equalTo(avatar)
            make.right.equalTo(rightActions.snp.left).offset(-8)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.height.equalTo(30)
            make.bottom.equalTo(lastMessageLabel)
        }
        
        rightActions.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.height.equalTo(30)
            make.bottom.equalTo(lastMessageLabel)
        }
    }
    
    
    override func bindData(_ data: WFCCFriendRequest?) {
        guard let data else {
            return
        }
        
        if let userInfo = WFCCIMService.sharedWFCIM().getUserInfo(data.target ?? "", refresh: false) {
            avatar.sd_setImage(with: .init(string: userInfo.portrait ?? .init()), placeholderImage: Images.icon_logo)
            userNameLabel.text = userInfo.displayName ?? ""
        }
        lastMessageLabel.text = data.reason
        
        if data.status == 1 {
            acceptButton.isHidden = true
            ignoreButton.isHidden = true
            statusLabel.isHidden = false
            statusLabel.text = "已同意"
        } else if data.status == 0 {
            acceptButton.isHidden = false
            ignoreButton.isHidden = false
            statusLabel.isHidden = true
        } else if data.status == 2 {
            acceptButton.isHidden = true
            ignoreButton.isHidden = true
            statusLabel.isHidden = false
            statusLabel.text = "已拒绝"
        } else {
            acceptButton.isHidden = true
            ignoreButton.isHidden = true
            statusLabel.isHidden = true
        }
        
    }
    
    @objc func didClickIgnoreButton(_ sender: UIButton) {
        guard let request = cellData, let indexPath = self.indexPath else {
            return
        }
        delegate?.onIgnore(request, at: indexPath)
    }
    
    @objc func didClickAcceptButton(_ sender: UIButton) {
        guard let request = cellData, let indexPath = self.indexPath else {
            return
        }
        delegate?.onAccept(request, at: indexPath)
    }
}

