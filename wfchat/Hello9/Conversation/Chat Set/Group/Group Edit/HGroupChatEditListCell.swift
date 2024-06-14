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
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureSubviews() {
        isUserInteractionEnabled = false
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
    }
    
    private func makeConstraints() {
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




class HGroupChatEditListCell: HBasicCollectionViewCell<HGroupChatEditModel> {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system16
        label.textColor = Colors.themeBlack
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .system14
        label.textColor = Colors.themeGray4
        return label
    }()
    
    private lazy var icon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
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
        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
    }
    
    private func makeConstraints() {
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
    
    override func bindData(_ data: HGroupChatEditModel?) {
        guard let data else {
            return
        }
        
        icon.image = data.icon
        titleLabel.text = data.title
        subTitleLabel.text = data.value
    }
}

