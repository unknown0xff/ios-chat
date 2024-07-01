//
//  HNodeSourceSetCell.swift
//  Hello9
//
//  Created by Ada on 2024/7/1.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HNodeSourceSetCell: HBasicTableViewCell<Void> {
    
    private lazy var icon: UIImageView = {
        let view = UIImageView()
        view.image = Images.icon_resource
        view.contentMode = .scaleAspectFit
        view.backgroundColor = UIColor(rgb: 0x35c759)
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system16
        label.textColor = Colors.themeBlack
        label.text = "资源分享设置"
        return label
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        accessoryType = .disclosureIndicator
        separatorView.isHidden = true
        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        icon.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.width.height.equalTo(32)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(16)
            make.centerY.equalToSuperview()
        }
    }
    
}
