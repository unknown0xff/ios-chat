//
//  HCommonTextFieldContentView.swift
//  Hello9
//
//  Created by Ada on 2024/6/26.
//  Copyright © 2024 Hello9. All rights reserved.
//

import UIKit

class HCommonTextFieldContentView: UIView {
    
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system14
        label.textColor = Colors.themeGray2
        return label
    }()
    
    private(set) lazy var textField: UITextField = {
        let field = UITextField.default
        return field
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubviews() {
        addSubview(titleLabel)
        addSubview(textField)
    }
    
    func makeConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.left.top.equalTo(0)
            make.height.equalTo(22)
        }
        
        textField.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.right.equalTo(0)
            make.height.equalTo(26)
            make.bottom.equalTo(0)
        }
    }

}
