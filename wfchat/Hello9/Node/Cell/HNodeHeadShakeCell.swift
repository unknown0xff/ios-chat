//
//  HNodeHeadShakeCell.swift
//  Hello9
//
//  Created by Ada on 2024/7/2.
//  Copyright © 2024 Hello9. All rights reserved.
//

import UIKit
import Lottie

class HNodeHeadShakeCell: HBasicTableViewCell<Void> {
    
    private lazy var topImage = UIImageView(image: Images.icon_node_shake)
    private lazy var topTitleBgImage = UIImageView(image: Images.icon_node_subtitle_bg)
    private lazy var topTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "做贡献、得积分、抢靓号"
        label.textColor = Colors.white
        label.font = .system14.medium
        return label
    }()
    
    private(set) lazy var shakeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(Images.icon_node_yaoyiyao, for: .normal)
        return btn
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        selectionStyle = .none
        backgroundColor = .clear
        separatorView.isHidden = true
        contentView.backgroundColor = .clear
        
        contentView.addSubview(topImage)
        contentView.addSubview(topTitleBgImage)
        contentView.addSubview(topTitleLabel)
        contentView.addSubview(shakeButton)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        topImage.snp.makeConstraints { make in
            make.top.equalTo(67)
            make.centerX.equalToSuperview()
            make.width.equalTo(260)
            make.height.equalTo(64)
        }
        
        topTitleBgImage.snp.makeConstraints { make in
            make.top.equalTo(topImage.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.width.equalTo(186)
            make.height.equalTo(31)
        }
        
        topTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(topImage.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.width.equalTo(186)
            make.height.equalTo(31)
        }
        
        shakeButton.snp.makeConstraints { make in
            make.bottom.equalTo(-22)
            make.width.equalTo(167)
            make.height.equalTo(53)
            make.centerX.equalToSuperview()
        }
    }
    
    override func bindData(_ data: Void?) {
        
    }
    
}

