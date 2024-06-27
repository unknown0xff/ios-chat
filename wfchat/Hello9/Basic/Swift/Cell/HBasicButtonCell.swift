//
//  HBasicButtonCell.swift
//  Hello9
//
//  Created by Ada on 2024/6/21.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HBasicButtonCell: HBasicCollectionViewCell<String> {
    
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system16.bold
        label.textColor = Colors.themeRed1
        label.textAlignment = .center
        return label
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        contentView.addSubview(titleLabel)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        titleLabel.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
            make.height.equalTo(26)
        }
    }
    
    override func bindData(_ data: String?) {
        titleLabel.text = data
    }
}
