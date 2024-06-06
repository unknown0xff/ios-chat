//
//  HSingleChatSetHeadCell.swift
//  hello9
//
//  Created by Ada on 6/3/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import UIKit

class HSingleChatSetHeadCell: HBasicTableViewCell<HUserInfoModel> {
    
    private lazy var backgroundImageView: UIImageView = {
        let image = UIImageView(image: Images.icon_background)
        return image
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .system28.bold
        label.textColor = Colors.gray03
        return label
    }()
    
    private lazy var userIdLabel: UILabel = {
        let label = UILabel()
        label.font = .system12
        label.textColor = Colors.gray03
        return label
    }()
    
    private lazy var signLabel: UILabel = {
        let label = UILabel()
        label.font = .system12
        label.numberOfLines = 2
        label.textColor = Colors.gray06
        return label
    }()
    
    private lazy var avatar: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 45
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = Colors.yellow01
        return imageView
    }()
    
    private lazy var secretButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.setImage(Images.icon_secret, for: .normal)
        return btn
    }()
    
    
    private lazy var moreButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.setImage(Images.icon_more, for: .normal)
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureSubviews() {
        
        selectionStyle = .none
        
        contentView.addSubview(backgroundImageView)
        
        contentView.addSubview(userIdLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(signLabel)
        contentView.addSubview(avatar)
        contentView.addSubview(secretButton)
        contentView.addSubview(moreButton)
    }
    
    private func makeConstraints() {
        
        backgroundImageView.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.width.equalTo(UIScreen.width)
            make.height.equalTo(UIScreen.width * 222 / 390)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(46)
            make.top.equalTo(backgroundImageView.snp.bottom).offset(16)
            make.height.equalTo(42)
            make.right.equalTo(avatar.snp.left).offset(-4)
        }
        
        userIdLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.left)
            make.right.equalTo(nameLabel.snp.right)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.height.equalTo(16)
        }
        
        signLabel.snp.makeConstraints { make in
            make.left.equalTo(userIdLabel.snp.left)
            make.right.equalTo(-24)
            make.top.equalTo(userIdLabel.snp.bottom).offset(16)
        }
        
        avatar.snp.makeConstraints { make in
            make.right.equalTo(-UIScreen.width.multipliedBy(0.1))
            make.height.width.equalTo(94)
            make.top.equalTo(backgroundImageView.snp.bottom).offset(-24)
        }
        
        secretButton.snp.makeConstraints { make in
            make.left.equalTo(signLabel.snp.left)
            make.height.equalTo(72)
            make.width.equalTo(72 * 703.0 / 306.0)
            make.top.equalTo(signLabel.snp.bottom).offset(36)
            make.bottom.equalTo(-36)
        }
        
        moreButton.snp.makeConstraints { make in
            make.left.equalTo(secretButton.snp.right).offset(8)
            make.top.equalTo(secretButton.snp.top)
            make.height.equalTo(secretButton)
            make.width.equalTo(72)
        }
    }
    
    override func bindData(_ data: HUserInfoModel?) {
        nameLabel.text = data?.title
        userIdLabel.text = "hello号：\(data?.name ?? "")"
        avatar.sd_setImage(with: data?.portrait, placeholderImage: Images.icon_logo, context: nil)
    }
}

