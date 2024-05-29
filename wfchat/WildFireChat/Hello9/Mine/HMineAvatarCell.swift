//
//  HMineAvatarCell.swift
//  hello9
//
//  Created by Ada on 5/29/24.
//  Copyright © 2024 hello9. All rights reserved.
//


import UIKit

class HMineAvatarCell: HBasicTableViewCell<UIImage> {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system12
        label.text = "您的Hello号是"
        label.sizeToFit()
        return label
    }()
    
    private lazy var stack: UIStackView = {
        let s = UIStackView()
        s.alignment = .leading
        return s
    }()
    
    private lazy var textField: UITextField = {
        let field = UITextField()
        return field
    }()
    
    private lazy var leftIcon: UIImageView = {
        let imageView = UIImageView()
        
        return imageView
    }()
    
    
    private lazy var rightIcon: UIImageView = {
        let imageView = UIImageView()
        return imageView
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
        
    }
    
    private func makeConstraints() {
        
    }
    
    override func bindData(_ data: UIImage?) {
        
    }
}

