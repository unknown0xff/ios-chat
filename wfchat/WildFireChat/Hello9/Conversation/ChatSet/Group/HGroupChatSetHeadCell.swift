//
//  HGroupChatSetHeadCell.swift
//  hello9
//
//  Created by Ada on 6/3/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import UIKit

class HGroupChatSetHeadCell: HBasicTableViewCell<HGroupInfo> {
    
    private lazy var backgroundImageView: UIImageView = {
        let image = UIImageView(image: Images.icon_background)
        return image
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .system18.bold
        label.textColor = Colors.white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var groupNumberLabel: UILabel = {
        let label = UILabel()
        label.font = .system12.medium
        label.textColor = Colors.white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var avatar: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 41
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = Colors.yellow01
        return imageView
    }()
    
    private lazy var actionView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            muteButton, searchButton, moreButton
        ])
        view.spacing = 10
        view.alignment = .fill
        view.distribution = .fillEqually
        view.axis = .horizontal
        return view
    }()
    
    private lazy var muteButton: UIButton = {
        let btn = buttonWithImage(Images.icon_bell)
        return btn
    }()
    
    private lazy var searchButton: UIButton = {
        let btn = buttonWithImage(Images.icon_search)
        return btn
    }()
    
    private lazy var moreButton: UIButton = {
        let btn = buttonWithImage(Images.icon_more_dot)
        return btn
    }()
    
    private func buttonWithImage(_ image: UIImage) -> UIButton {
        let btn = UIButton(type: .system)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.setImage(image, for: .normal)
        btn.backgroundColor = Colors.white
        btn.layer.cornerRadius = 15
        return btn
    }
    
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
        
        contentView.addSubview(groupNumberLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(avatar)
        
        contentView.addSubview(actionView)
    }
    
    private func makeConstraints() {
        
        backgroundImageView.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.width.height.equalToSuperview()
        }
        
        avatar.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.width.equalTo(82)
            make.top.equalTo(76)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(24)
            make.right.equalTo(-24)
            make.top.equalTo(avatar.snp.bottom).offset(6)
            make.height.equalTo(27)
        }
        
        groupNumberLabel.snp.makeConstraints { make in
            make.left.right.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.height.equalTo(18)
        }
        
        actionView.snp.makeConstraints { make in
            make.left.equalTo(24)
            make.right.equalTo(-24)
            make.height.equalTo(56)
            make.top.equalTo(groupNumberLabel.snp.bottom).offset(38)
            make.bottom.equalTo(-20)
        }
    }
    
    override func bindData(_ data: HGroupInfo?) {
        nameLabel.text = data?.displayName
        groupNumberLabel.text = "\(data?.memberCount ?? 0)个成员"
        avatar.sd_setImage(with: data?.portrait, placeholderImage: Images.icon_logo, context: nil)
    }
}

