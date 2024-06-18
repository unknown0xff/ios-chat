//
//  HFriendSearchListCell.swift
//  Hello9
//
//  Created by Ada on 2024/6/18.
//  Copyright © 2024 Hello9. All rights reserved.
//


class HFriendSearchListCell: HBasicTableViewCell<HFriendSearchListModel> {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system17.bold
        label.textColor = Colors.themeBlack
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .system14
        label.text = "Hello号查找"
        label.textColor = Colors.themeGray3
        return label
    }()
    
    private lazy var actionLabel: UILabel = {
        let label = UILabel()
        label.font = .system13
        label.textColor = Colors.themeBlack
        label.layer.borderColor = Colors.themeGray2.cgColor
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var avatar: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        
        selectionStyle = .none
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(avatar)
        contentView.addSubview(actionLabel)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        avatar.snp.makeConstraints { make in
            make.top.equalTo(17)
            make.left.equalTo(16)
            make.width.height.equalTo(48)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(avatar.snp.right).offset(12)
            make.top.equalTo(avatar)
            make.right.equalTo(actionLabel.snp.left).offset(-8)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(avatar.snp.right).offset(12)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.right.equalTo(titleLabel)
        }
        actionLabel.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.height.equalTo(29)
            make.width.equalTo(56)
            make.centerY.equalToSuperview()
        }
    }
    
    override func bindData(_ data: HFriendSearchListModel?) {
        guard let data else { return }
        if data.isGroup {
            actionLabel.text = "申请"
        } else {
            actionLabel.text = "添加"
        }
        
        avatar.sd_setImage(with: data.portrait, placeholderImage: data.portraitPlaceholder, context: nil)
        titleLabel.text = data.title
    }
}

class HFriendSearchGroupHeaderCell: HBasicTableViewCell<String> {
    
    private lazy var gap = UIView()
    private lazy var titleLabel = UILabel()
    
    override func configureSubviews() {
        super.configureSubviews()
        
        separatorView.isHidden = true
        contentView.addSubview(gap)
        contentView.addSubview(titleLabel)
        
        gap.backgroundColor = Colors.themeGray4Background
        titleLabel.text = "群聊"
        titleLabel.font = .system14.bold
        
        gap.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(gap.snp.bottom).offset(20)
        }
    }
}
