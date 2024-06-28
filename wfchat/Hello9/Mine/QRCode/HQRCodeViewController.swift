//
//  HQRCodeViewController.swift
//  Hello9
//
//  Created by Ada on 2024/6/27.
//  Copyright © 2024 Hello9. All rights reserved.
//


class HQRCodeViewController: HBaseViewController {
    
    enum QRType {
        case user
        case group
    }
    
    let target: String
    let type: QRType
    var qrString: String {
        if type == .group {
            return HAppScheme.group(target).rawValue
        } else {
            return HAppScheme.user(target).rawValue
        }
    }
    
    var url: URL? {
        if type == .group {
            let groupInfo = WFCCIMService.sharedWFCIM().getGroupInfo(target, refresh: false)
            if let p = groupInfo?.portrait {
                return .init(string: p)
            }
        } else {
            let userInfo = WFCCIMService.sharedWFCIM().getUserInfo(target, refresh: false)
            if let p = userInfo?.portrait {
                return .init(string: p)
            }
        }
        return nil
    }
    
    private lazy var scrollerView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = .clear
        scroll.alwaysBounceVertical = true
        scroll.alwaysBounceHorizontal = false
        return scroll
    }()
    
    private lazy var qrBackgroundView: UIView = UIView()
    private lazy var qrCodeView: UIImageView = UIImageView()
    private lazy var avatarView: UIImageView = UIImageView()
    
    init(target: String, type: QRType) {
        self.type = type
        self.target = target
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDefaultStyle()
        backgroundView.image = Images.icon_background_green_full
        
        qrBackgroundView.backgroundColor = Colors.white
        qrBackgroundView.layer.cornerRadius = 42
        
        avatarView.layer.cornerRadius = 50
        avatarView.layer.masksToBounds = true
        
        qrCodeView.contentMode = .scaleAspectFit
        
        view.addSubview(scrollerView)
        scrollerView.addSubview(qrBackgroundView)
        scrollerView.addSubview(qrCodeView)
        scrollerView.addSubview(avatarView)
        
        scrollerView.snp.makeConstraints { make in
            make.left.right.width.bottom.equalToSuperview()
            make.top.equalTo(navBar.snp.bottom)
        }
        
        qrBackgroundView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(46)
            make.width.equalToSuperview().offset(-92)
            make.height.equalTo(qrBackgroundView.snp.width).multipliedBy(1.1)
        }
        
        qrCodeView.snp.makeConstraints { make in
            make.top.equalTo(qrBackgroundView).offset(40)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(qrBackgroundView.snp.width).offset(-80)
        }
        
        avatarView.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.bottom.equalTo(qrBackgroundView.snp.top).offset(30)
            make.centerX.equalToSuperview()
        }
        
        avatarView.sd_setImage(with: url)
        qrCodeView.image = UIImage.generateQRCode(from: qrString, size: .init(width: 500, height: 500))
    }
    
}
