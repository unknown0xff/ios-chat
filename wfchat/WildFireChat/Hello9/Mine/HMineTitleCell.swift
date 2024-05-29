//
//  HMineTitleCell.swift
//  hello9
//
//  Created by Ada on 5/29/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import UIKit

class HMineTitleCell: HBasicTableViewCell<HMineTitleCellModel> {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system16
        label.textColor = Colors.gray03
        return label
    }()
    
    private lazy var leftIcon: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var progressView: UIStackView = {
        let view = UIStackView()
        
        return view
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
        contentView.addSubview(leftIcon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(progressView)
    }
    
    private func makeConstraints() {
        leftIcon.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.left.equalTo(48)
            make.top.equalTo(18)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(leftIcon.snp.right).offset(20)
            make.centerY.equalTo(leftIcon)
        }
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.equalTo(titleLabel)
            make.right.equalTo(48)
            make.height.equalTo(41)
            make.bottom.equalTo(-16)
        }
    }
    
    override func bindData(_ data: HMineTitleCellModel?) {
        guard let data else {
            return
        }
        
        titleLabel.text = data.title
        leftIcon.image = data.image
        
        switch data.tag {
        case .verify(let progress):
            progressView.snp.updateConstraints { make in
                make.height.equalTo(41)
            }
        case .setting, .feedback,.logout:
            progressView.snp.updateConstraints { make in
                make.height.equalTo(1)
            }
        }
    }
    
}

