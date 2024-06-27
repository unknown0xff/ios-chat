//
//  HSingleAccountView.swift
//  Hello9
//
//  Created by Ada on 6/13/24.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HSingleAccountView: UIControl {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system14
        label.text = "Hello账号"
        label.textColor = Colors.themeGray2
        return label
    }()
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .system16
        label.textColor = Colors.themeBlue1
        label.textAlignment = .center
        return label
    }()
    
    private lazy var qrCodeView: UIImageView = .init(image: Images.icon_qr_code)
    
    var userInfo: HUserInfoModel {
        didSet {
            loadData()
        }
    }
    
    init(frame: CGRect = .zero, userInfo: HUserInfoModel = .init(info: nil)) {
        self.userInfo = userInfo
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(userNameLabel)
        addSubview(qrCodeView)
        
        titleLabel.snp.makeConstraints { make in
            make.left.top.equalTo(16)
            make.height.equalTo(22)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.height.equalTo(26)
            make.bottom.equalTo(-12)
        }
        
        let space = UILabel()
        space.backgroundColor = Colors.themeSeperatorColor
        addSubview(space)
        space.snp.makeConstraints { make in
            make.bottom.left.width.equalToSuperview()
            make.height.equalTo(1)
        }
        
        qrCodeView.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.width.height.equalTo(24)
            make.centerY.equalTo(userNameLabel)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadData() {
        userNameLabel.text = "@\(userInfo.displayName)"
    }
}

class HSingleInfoView: UIView {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system14
        label.text = "个人简介"
        label.textColor = Colors.themeGray2
        return label
    }()
    
    private lazy var signLabel: UILabel = {
        let label = UILabel()
        label.font = .system16
        label.textColor = Colors.themeBlack
        label.numberOfLines = 0
        return label
    }()
    
    var userInfo: HUserInfoModel {
        didSet {
            reloaData()
        }
    }
    
    init(frame: CGRect = .zero, userInfo: HUserInfoModel = .init(info: nil)) {
        self.userInfo = userInfo
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(signLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.left.top.equalTo(16)
            make.height.equalTo(22)
        }
        
        signLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalTo(-16)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.bottom.equalTo(-12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloaData() {
        signLabel.text = "\(userInfo.social)"
    }
    
}
