//
//  HSelectedFriendCell.swift
//  hello9
//
//  Created by Ada on 5/31/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import Foundation

class HSelectedFriendCell: HBasicTableViewCell<WFCCUserInfo> {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system16.bold
        label.textColor = Colors.gray03
        return label
    }()
    
    private lazy var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = Colors.gray07
        imageView.layer.cornerRadius = 30
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
    
    private func configureSubviews() {
        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
    }
    
    private func makeConstraints() {
        icon.snp.makeConstraints { make in
            make.left.equalTo(24)
            make.width.height.equalTo(60)
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(icon)
            make.left.equalTo(icon.snp.right).offset(16)
            make.right.equalTo(-24)
        }
    }
    
    override func bindData(_ data: WFCCUserInfo?) {
        let portrait = data?.portrait ?? ""
        
        icon.sd_setImage(with: URL(string: portrait), placeholderImage: Images.icon_logo)
        
        let title: String
        if let friendAlias = data?.friendAlias,
            !friendAlias.isEmpty {
            title = friendAlias
        } else {
            title = data?.displayName ?? ""
        }
        titleLabel.text = title
    }
}

