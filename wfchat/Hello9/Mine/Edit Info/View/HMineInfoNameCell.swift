//
//  HMineInfoNameCell.swift
//  Hello9
//
//  Created by Ada on 2024/6/20.
//  Copyright © 2024 Hello9. All rights reserved.
//

import Foundation

class HTextField: UITextField {
    var indexPath: IndexPath?
}

class HMineInfoNameCell: HBasicCollectionViewCell<String> {
    
    private(set) lazy var textField: HTextField = {
        let tf = HTextField.default
        return tf
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        selectedBackgroundColor = .white
        contentView.addSubview(textField)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        textField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
            make.height.equalTo(58)
        }
    }
    
    override func bindData(_ data: String?) {
        textField.placeholder = indexPath.item == 0 ? "名字" : "姓氏"
        textField.indexPath = indexPath
        textField.text = data
    }
}

