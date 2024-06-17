//
//  HSelectedActionCell.swift
//  hello9
//
//  Created by Ada on 5/31/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import UIKit

class HSelectedActionCell: HBasicTableViewCell<HSelectActionType> {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system14
        label.textColor = Colors.gray03
        return label
    }()
    
    private lazy var iconBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray07
        view.addSubview(icon)
        view.layer.cornerRadius = 22
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var icon: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    
    override func configureSubviews() {
        super.configureSubviews()
        contentView.addSubview(iconBackgroundView)
        contentView.addSubview(titleLabel)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        iconBackgroundView.snp.makeConstraints { make in
            make.left.equalTo(24)
            make.width.height.equalTo(44)
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
        }
        
        icon.snp.makeConstraints { make in
            make.width.height.equalTo(18)
            make.center.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(iconBackgroundView)
            make.left.equalTo(iconBackgroundView.snp.right).offset(12)
        }
    }
    
    override func bindData(_ data: HSelectActionType?) {
        titleLabel.text = data?.title
        icon.image = data?.image
    }
}

fileprivate extension HSelectActionType {
    
    var title: String {
        switch self {
        case .addFriend:
            return "添加好友"
        case .group:
            return "新建群组或频道"
        case .secret:
            return "新建私密群"
        }
    }
    
    var image: UIImage {
        switch self {
        case .addFriend:
            return Images.icon_add_friend
        case .group:
            return Images.icon_group
        case .secret:
            return Images.icon_light
        }
    }
}
