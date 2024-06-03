//
//  HMessageNavBar.swift
//  hello9
//
//  Created by Ada on 6/3/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import UIKit

class HMessageNavBar: UIView {
    
    private(set) lazy var backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(Images.icon_back.withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    
    private(set) lazy var moreButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(Images.icon_widgets.withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    
    private(set) lazy var avatar: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 19
        view.layer.masksToBounds = true
        return view
    }()
    
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system14.medium
        label.textColor = Colors.gray03
        label.textAlignment = .center
        return label
    }()
    
    private(set) lazy var bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.black.withAlphaComponent(0.03)
        return view
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        backgroundColor = Colors.white
        
        addSubview(backButton)
        
        addSubview(titleLabel)
        addSubview(avatar)
        addSubview(bottomLine)
        
        addSubview(moreButton)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(50)
            make.bottom.equalTo(-16)
            make.height.equalTo(21)
            make.right.equalTo(-50)
        }
        
        avatar.snp.makeConstraints { make in
            make.width.height.equalTo(38)
            make.bottom.equalTo(titleLabel.snp.top).offset(-8)
            make.centerX.equalToSuperview()
        }
        
        bottomLine.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        backButton.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.bottom.equalTo(-42)
            make.height.equalTo(24)
        }
        
        moreButton.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.bottom.equalTo(-42)
            make.height.equalTo(24)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
