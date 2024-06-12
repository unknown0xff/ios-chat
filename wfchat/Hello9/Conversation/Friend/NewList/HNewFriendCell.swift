//
//  HNewFriendCell.swift
//  hello9
//
//  Created by Ada on 6/5/24.
//  Copyright © 2024 hello9. All rights reserved.
//


import UIKit

protocol HNewFriendCellDelegate: AnyObject {
    func onDetail(_ request: WFCCFriendRequest, at indexPath: IndexPath)
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
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "已同意"
        label.font = .system13
        label.textColor = Colors.themeButtonDisable
        return label
    }()
    
    private lazy var detailButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 1
        btn.layer.borderColor = Colors.theme2.cgColor
        btn.titleLabel?.font = .system13
        btn.setTitle("查看", for: .normal)
        btn.setTitleColor(Colors.themeBlack, for: .normal)
        btn.addTarget(self, action: #selector(didClickAcceptButton(_:)), for: .touchUpInside)
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
    
    private func configureSubviews() {
        
        selectedBackgroundColor = Colors.white
        contentView.addSubview(avatar)
        
        rightContent.addArrangedSubview(userNameLabel)
        rightContent.addArrangedSubview(lastMessageLabel)
        contentView.addSubview(rightContent)
        
        contentView.addSubview(detailButton)
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
            make.right.equalTo(detailButton.snp.left).offset(-8)
        }
        
        detailButton.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.height.equalTo(30)
            make.width.equalTo(56)
            make.centerY.equalTo(avatar)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.height.equalTo(30)
            make.centerY.equalTo(avatar)
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
        
        if data.direction == 1 {
            lastMessageLabel.text = "请求添加为好友"
        } else {
            lastMessageLabel.text = "请求添加对方为好友"
        }
        if data.status == 1 {
            detailButton.isHidden = true
            statusLabel.isHidden = false
            statusLabel.text = "已同意"
        } else if data.status == 0 {
            if data.direction == 1 {
                detailButton.isHidden = false
                statusLabel.isHidden = true
            } else {
                detailButton.isHidden = true
                statusLabel.isHidden = false
                statusLabel.text = "等待验证"
            }
        } else if data.status == 2 {
            detailButton.isHidden = true
            statusLabel.isHidden = false
            statusLabel.text = "已拒绝"
        } else {
            detailButton.isHidden = true
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
        delegate?.onDetail(request, at: indexPath)
    }
}

