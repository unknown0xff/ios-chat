//
//  HGroupChatEditListCell.swift
//  Hello9
//
//  Created by Ada on 6/14/24.
//  Copyright © 2024 Hello9. All rights reserved.
//

import UIKit

class HGroupChatEditSubTitleCell: HBasicCollectionViewCell<HGroupChatEditModel> {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system14
        label.textColor = Colors.themeGray2
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .system16
        label.numberOfLines = 0
        label.textColor = Colors.themeBlack
        return label
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        
        isUserInteractionEnabled = false
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalTo(16)
            make.height.equalTo(22)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.right.equalTo(-16)
            make.bottom.equalTo(-12)
        }
    }
    
    override func bindData(_ data: HGroupChatEditModel?) {
        guard let data else {
            return
        }
        
        titleLabel.text = data.title
        subTitleLabel.text = data.value
    }
}

class HGroupChatEditListCell: HCollectionViewListCell<HGroupChatEditModel> {
    
    override func bindData(_ data: HGroupChatEditModel?) {
        guard let data else {
            return
        }
        
        icon.image = data.icon
        titleLabel.text = data.title
        subTitleLabel.text = data.value
    }
}
