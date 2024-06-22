//
//  HMessageLocationCell.swift
//  Hello9
//
//  Created by Ada on 2024/6/22.
//  Copyright © 2024 Hello9. All rights reserved.
//

import Foundation

class HMessageLocationCell: HMessageCell<WFCCLocationMessageContent> {
    
    private lazy var locationIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        bubbleView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.width.height.equalTo(24)
        }
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system15
        label.textColor = Colors.themeBlack
        label.textAlignment = .left
        
        bubbleView.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(34)
            make.right.equalTo(0)
            make.height.equalTo(24)
            make.bottom.equalTo(0)
        }
        return label
    }()
    
    private lazy var locationView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        bubbleView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.right.left.equalTo(0)
            make.top.equalTo(8)
            make.bottom.equalTo(-32)
        }
        return imageView
    }()
    
    override class func size(of content: WFCCLocationMessageContent) -> CGSize {
        var size = content.thumbnail.size
        let aspect = size.width / size.height
        size.width = min(UIScreen.width / 2, size.width)
        size.height = size.width / aspect
        
        size.height += 40
        return size
    }
    
    override func bindData(_ content: WFCCLocationMessageContent) {
        locationView.image = content.thumbnail
        titleLabel.text = content.title
        locationIcon.image = Images.icon_location
        bubbleView.image = nil
        dateLabel.text = ""
    }
}
