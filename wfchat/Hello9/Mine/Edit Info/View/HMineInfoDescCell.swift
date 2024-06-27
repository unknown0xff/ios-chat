//
//  HMineInfoDescCell.swift
//  Hello9
//
//  Created by Ada on 2024/6/27.
//  Copyright © 2024 Hello9. All rights reserved.
//
//  个人简介/描述
//

import Foundation

class HMineInfoDescCell: HBasicCollectionViewCell<String> {
    
    private(set) lazy var textView: HTextView = {
        let tv = HTextView()
        tv.textColor = Colors.themeBlack
        tv.font = .system16
        tv.showsHorizontalScrollIndicator = false
        tv.showsVerticalScrollIndicator = false
        tv.placeholder = "个人简介"
        return tv
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        selectedBackgroundColor = .white
        contentView.addSubview(textView)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
            make.height.equalTo(30)
        }
    }
    
    override func bindData(_ data: String?) {
        textView.text = data
    }
}
