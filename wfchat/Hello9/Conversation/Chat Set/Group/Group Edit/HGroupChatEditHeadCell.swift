//
//  HGroupChatEditHeadCell.swift
//  Hello9
//
//  Created by Ada on 6/14/24.
//  Copyright © 2024 Hello9. All rights reserved.
//

import UIKit

class HGroupChatEditHeadCell: HBasicCollectionViewCell<URL> {
    
    private lazy var avatar: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = Colors.themeBlue2
        view.layer.masksToBounds = true
        view.layer.borderWidth = 2
        view.layer.borderColor = Colors.white.cgColor
        view.layer.cornerRadius = 51
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system18
        label.text = "设置新照片或视频"
        label.textColor = Colors.themeBlue1
        return label
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        
        selectedBackgroundColor = .clear
        unselectedBackgroundColor = .clear
        contentView.addSubview(avatar)
        contentView.addSubview(titleLabel)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        avatar.snp.makeConstraints { make in
            make.width.height.equalTo(102)
            make.top.equalTo(10)
            make.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(avatar.snp.bottom).offset(20)
            make.height.equalTo(29)
            make.bottom.equalTo(-12)
        }
    }
    
    override func bindData(_ data: URL?) {
        avatar.sd_setImage(with: data, placeholderImage: Images.icon_camera) { [weak self] image, _, _, _ in
            if let _ = image {
                self?.avatar.contentMode = .scaleAspectFit
            } else {
                self?.avatar.contentMode = .center
            }
        }
    }
}
