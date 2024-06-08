//
//  HLoginCell.swift
//  ios-hello9
//
//  Created by Ada on 5/29/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import Foundation
import UIKit

struct HLoginCellModel: Hashable {
    var isNewUser = true
    var isValid = false
    var buttonOnly = false
}

class HLoginCell: HBasicTableViewCell<HLoginCellModel> {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system12
        label.textColor = Colors.themeGray3
        label.numberOfLines = 2
        
        let attr = NSMutableAttributedString(
            string: "*",
            attributes: [.font : UIFont.system12, .foregroundColor: Colors.themeRed2, .kern: 0.5])
        let attr1 = NSMutableAttributedString(
            string: "已分配账户，您可直接注册或修改密码后登录",
            attributes: [.font : UIFont.system12, .foregroundColor: Colors.themeGray3])
        attr.append(attr1)
        label.attributedText = attr
        return label
    }()
    
    private(set) lazy var forgetButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("忘记密码?", for: .normal)
        btn.setTitleColor(Colors.themeBlack, for: .normal)
        btn.titleLabel?.font = .system14.medium
        return btn
    }()
    
    private(set) lazy var loginButton: UIButton = .loginButton
    
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
        if data.buttonOnly {
            forgetButton.isHidden = true
            titleLabel.isHidden = true
        } else {
            forgetButton.isHidden = data.isNewUser
            titleLabel.isHidden = !data.isNewUser
        }
        loginButton.isEnabled = data.isValid
    }
    
    private func configureSubviews() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
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
            make.top.equalTo(3)
            make.right.equalTo(-30)
        }
        
        loginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(73)
            make.width.height.equalTo(62)
            make.bottom.equalTo(-66)
        }
        
    }
    
}

