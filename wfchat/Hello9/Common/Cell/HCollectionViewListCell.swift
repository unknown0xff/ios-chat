//
//  HCollectionViewListCell.swift
//  Hello9
//
//  Created by Ada on 6/15/24.
//  Copyright © 2024 Hello9. All rights reserved.
//


class HCollectionViewListCell<T>: HBasicCollectionViewCell<T> {
    
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system16
        label.textColor = Colors.themeBlack
        return label
    }()
    
    private(set) lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .system14
        label.textColor = Colors.themeGray4
        return label
    }()
    
    private(set) lazy var icon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        icon.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.left.equalTo(20)
            make.width.height.equalTo(32)
            make.bottom.equalTo(-20)
        }
    
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(16)
            make.centerY.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.right.equalTo(-6)
            make.centerY.equalToSuperview()
        }
    }
}

