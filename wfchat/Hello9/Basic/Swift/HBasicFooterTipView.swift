//
//  HBasicFooterTipView.swift
//  Hello9
//
//  Created by Ada on 2024/6/20.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HBasicFooterTipView: HBasicCollectionReusableView<String> {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system12
        label.textColor = Colors.themeButtonDisable
        return label
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(12)
            make.right.equalTo(-16)
        }
    }
    
    override func bindData(_ data: String?) {
        titleLabel.text = data
    }
}
