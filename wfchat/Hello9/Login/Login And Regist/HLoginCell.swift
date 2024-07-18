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
            string: "已分配账户，输入密码后注册",
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
    
    private(set) lazy var loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitleColor(Colors.white, for: .normal)
        btn.setTitleColor(Colors.themeButtonDisable, for: .disabled)
        btn.titleLabel?.font = .system16.bold
        btn.setBackgroundImage(
            UIImage.gradientImage(
                bounds: .init(x: 0, y: 0, width: UIScreen.width - 60, height: 54),
                colors: [Colors.themeBlue4, Colors.themeBlue1],
                startPoint: .init(x: 0.25, y: 0.5),
                endPoint: .init(x: 0.75, y: 0.5)
            ),
            for: .normal
        )
        
        btn.setBackgroundImage(
            UIImage.image(withColor: Colors.themeBlue2),
            for: .disabled
        )
        
        btn.backgroundColor = Colors.themeBlue1
        btn.layer.cornerRadius = 16
        btn.layer.masksToBounds = true
        return btn
    }()
    
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
        let title = data.isNewUser ? "注册并登录" : "登录"
        loginButton.setTitle(title, for: .normal)
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(titleLabel)
        contentView.addSubview(forgetButton)
        contentView.addSubview(loginButton)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
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
            make.top.equalTo(65)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(54)
            make.bottom.equalTo(-168)
        }
        
    }
    
}

