//
//  HNewFriendListTitleCell.swift
//  Hello9
//
//  Created by Ada on 6/11/24.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HNewFriendListTitleCell: HBasicCollectionViewCell<String> {
    
    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.textColor = Colors.themeBlack
        l.font = .system16.bold
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = false
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(16)
            make.height.equalTo(26)
            make.bottom.equalTo(-16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bindData(_ data: String?) {
        titleLabel.text = data
    }
    
}
