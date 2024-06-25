//
//  HMyFriendListCell.swift
//  Hello9
//
//  Created by Ada on 6/17/24.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HMyFriendListCell: HBasicTableViewCell<HMyFriendListModel> {
    
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
        selectionStyle = .none
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
        
        editIcon.isHidden = !data.enableMutiSelected
        
        if data.isInGroup {
            editIcon.image = Images.icon_disable_check
        } else {
            editIcon.image = data.isSelected ? Images.icon_selected: Images.icon_unselected
        }
        
        icon.sd_setImage(with: data.portrait, placeholderImage: Images.icon_logo)
        titleLabel.text = data.dispalyName
    }
}

