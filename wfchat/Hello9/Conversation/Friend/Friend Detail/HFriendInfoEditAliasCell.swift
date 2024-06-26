//
//  HFriendInfoEditAliasCell.swift
//  Hello9
//
//  Created by Ada on 2024/6/26.
//  Copyright © 2024 Hello9. All rights reserved.
//

import UIKit

class HFriendInfoEditAliasCell: HBasicCollectionViewCell<String> {
    
    private(set) lazy var aliasView: HCommonTextFieldContentView = {
        let view = HCommonTextFieldContentView()
        view.titleLabel.text = "好友备注"
        view.textField.placeholder = "请输入好友备注"
        return view
    }()
    
    override func configureSubviews() {
        contentView.addSubview(aliasView)
    }
    
    override func makeConstraints() {
        aliasView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 16, left: 16, bottom: 12, right: 16))
        }
    }
    
    override func bindData(_ data: String?) {
        aliasView.textField.text = data
    }
}
