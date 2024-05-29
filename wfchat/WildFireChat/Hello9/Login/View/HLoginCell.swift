//
//  HLoginCell.swift
//  ios-hello9
//
//  Created by Ada on 5/29/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import Foundation
import UIKit

struct HLoginCellModel {
    var isNewUser: Bool = true
    var isValid: Bool = false
}

class HLoginCell: HBasicTableViewCell<HLoginCellModel> {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system12
        label.textColor = Colors.gray03
        label.numberOfLines = 2
        label.text = "已为您分配账号，您可以直接注册或更改您的密码后登录"
        label.sizeToFit()
        return label
    }()
    
    private(set) lazy var forgetButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("忘记密码?", for: .normal)
        btn.setTitleColor(Colors.gray03, for: .normal)
        btn.titleLabel?.font = .system12
        return btn
    }()
    
    private(set) lazy var loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitleColor(Colors.white, for: .normal)
        btn.titleLabel?.font = .system18.bold
        btn.layer.cornerRadius = 32
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bindData(_ data: HLoginCellModel?) {
        let data = data ?? .init()
        loginButton.setTitle(data.isNewUser ? "注册并登录" : "登录", for: .normal)
        
        forgetButton.isHidden = data.isNewUser
        titleLabel.isHidden = !data.isNewUser
        loginButton.isEnabled = data.isValid
        loginButton.backgroundColor = data.isValid ? Colors.blue01 : Colors.blue01.withAlphaComponent(0.5)
    }
    
    private func configureSubviews() {
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(forgetButton)
        contentView.addSubview(loginButton)
    }
    
    private func makeConstraints() {
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.left.equalTo(32)
            make.right.equalTo(-32)
            make.height.lessThanOrEqualTo(30)
        }
        
        forgetButton.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.right.equalTo(-32)
        }
        
        loginButton.snp.makeConstraints { make in
            make.left.equalTo(32)
            make.right.equalTo(-32)
            make.top.equalTo(titleLabel.snp.bottom).offset(UIScreen.height.multipliedBy(0.1))
            make.height.equalTo(64)
            make.bottom.equalTo(-1)
        }
        
    }
    
}

