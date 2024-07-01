//
//  HNodeSpecialNumberFooterCell.swift
//  Hello9
//
//  Created by Ada on 2024/7/1.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HNodeSpecialNumberHeaderCell: HBasicTableViewCell<Void> {
    
    private lazy var image: UIImageView = {
        let imageView = UIImageView(image: Images.icon_top)
        
        return imageView
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        isUserInteractionEnabled = false
        backgroundColor = UIColor(rgb: 0xeffaff)
        contentView.backgroundColor = .clear
        contentView.addSubview(image)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        image.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(29)
            make.width.equalTo(74)
        }
    }
    
}


class HNodeSpecialNumberFooterCell: HBasicTableViewCell<Void> {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system17.bold
        label.textColor = Colors.white
        label.text = "查看更多"
        label.textAlignment = .center
        label.layer.cornerRadius = 16
        label.backgroundColor = Colors.themeBlue1
        label.layer.masksToBounds = true
        return label
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        selectionStyle = .none
        backgroundColor = UIColor(rgb: 0xeffaff)
        contentView.addSubview(titleLabel)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(50)
        }
    }
    
}
