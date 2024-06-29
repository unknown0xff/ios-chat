//
//  HGroupEditAddManagerCell.swift
//  Hello9
//
//  Created by Ada on 2024/6/29.
//  Copyright © 2024 Hello9. All rights reserved.
//

import UIKit

class HGroupEditAddManagerCell: HBasicTableViewCell<Void> {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system14.bold
        label.textColor = Colors.themeBlack
        return label
    }()
    
    private lazy var addIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = Colors.themeGray4Background
        return imageView
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        
        contentView.addSubview(addIcon)
        contentView.addSubview(titleLabel)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        addIcon.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(12)
            make.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(addIcon.snp.right).offset(12)
            make.right.equalTo(-44)
            make.centerY.equalToSuperview()
        }
        
    }
    
    override func bindData(_ data: Void?) {
        addIcon.image = Images.icon_add
        addIcon.contentMode = .center
        titleLabel.text = "添加管理员"
    }
}

