//
//  HCreateGroupMemberListCell.swift
//  Hello9
//
//  Created by Ada on 2024/6/18.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HCreateGroupMemberListCell: HBasicCollectionViewCell<HMyFriendListModel> {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system14.bold
        label.textColor = Colors.themeBlack
        return label
    }()
    
    private lazy var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = Colors.themeGray4Background
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var editIcon: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    
    override func configureSubviews() {
        super.configureSubviews()
        isUserInteractionEnabled = false
        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(editIcon)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        icon.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.width.height.equalTo(40)
            make.top.equalTo(16)
            make.bottom.equalTo(-16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(icon)
            make.left.equalTo(icon.snp.right).offset(12)
            make.right.equalTo(-24)
        }
        
        editIcon.snp.makeConstraints { make in
            make.centerY.equalTo(icon)
            make.right.equalTo(-33)
            make.width.height.equalTo(21)
        }
        
    }
    
    override func bindData(_ data: HMyFriendListModel?) {
        
        guard let data else { return }
        
        editIcon.isHidden = true
        editIcon.image = nil
        
        
        icon.sd_setImage(with: data.portrait, placeholderImage: Images.icon_logo)
        titleLabel.text = data.dispalyName
    }
}

class HCreateGroupMemberListHeaderCell: HBasicCollectionViewCell<String> {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system14.bold
        label.textColor = Colors.themeBlack
        label.text = "成员"
        return label
    }()
    
    private lazy var animationLineView: UIImageView = {
        let v = UIImageView(image: Images.icon_tab_line)
        return v
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        isUserInteractionEnabled = false
        contentView.addSubview(titleLabel)
        contentView.addSubview(animationLineView)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.left.equalTo(16)
            make.height.equalTo(22)
        }
        
        animationLineView.snp.makeConstraints { make in
            make.centerX.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.height.equalTo(4)
            make.width.equalTo(25)
            make.bottom.equalTo(0)
        }
    }
    
}
