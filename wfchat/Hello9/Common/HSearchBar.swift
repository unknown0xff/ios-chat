//
//  HSearchBar.swift
//  hello9
//
//  Created by Ada on 5/31/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import Foundation

class HSearchBar: UIControl {
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray08
        view.layer.cornerRadius = 24
        return view
    }()
    
    private lazy var leftView: UIImageView = {
        let img = UIImageView(image: Images.icon_search_gray)
        return img
    }()
    
    private(set) lazy var textField: UITextField = {
        let field = UITextField()
        field.textColor = Colors.black
        field.placeholder = "搜索Hello号或用户名"
        field.font = .system16
        return field
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        backgroundColor = Colors.white
        
        addSubview(contentView)
        contentView.addSubview(leftView)
        contentView.addSubview(textField)
        
        contentView.snp.makeConstraints { make in
            make.left.equalTo(24)
            make.right.equalTo(-24)
            make.height.equalTo(46)
            make.centerY.equalToSuperview()
        }
        
        leftView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        textField.snp.makeConstraints { make in
            make.left.equalTo(leftView.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
