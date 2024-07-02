//
//  HNodeHeadShakeCell.swift
//  Hello9
//
//  Created by Ada on 2024/7/2.
//  Copyright © 2024 Hello9. All rights reserved.
//
import UIKit

class HNodeHeadShakeCell: HBasicTableViewCell<Void> {
    
    private lazy var shakeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(Images.icon_node_yaoyiyao, for: .normal)
        return btn
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(shakeButton)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
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

