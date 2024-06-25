//
//  HMessageTopView.swift
//  Hello9
//
//  Created by Ada on 2024/6/25.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HMessageTopView: UIControl {
    
    private lazy var topLabel: UILabel = {
        let label = UILabel()
        label.font = .system16.bold
        label.text = "置顶消息"
        label.textColor = Colors.themeBlue1
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .system16
        label.textColor = Colors.themeBlack
        return label
    }()
    
    private(set) lazy var closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(Images.icon_close_blue, for: .normal)
        return btn
    }()
    
    var message: WFCCMessage {
        didSet {
            loadData()
        }
    }
    
    init(message: WFCCMessage) {
        self.message = message
        super.init(frame: .zero)
        
        let gap = UIView()
        gap.backgroundColor = Colors.themeBlue1
        gap.layer.cornerRadius = 1
        
        addSubview(gap)
        addSubview(topLabel)
        addSubview(messageLabel)
        addSubview(closeButton)
        
        gap.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.height.equalTo(34)
            make.width.equalTo(2)
            make.centerY.equalToSuperview()
        }
        
        topLabel.snp.makeConstraints { make in
            make.left.equalTo(24)
            make.top.equalTo(8)
            make.height.equalTo(26)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.left.equalTo(topLabel.snp.left)
            make.top.equalTo(topLabel.snp.bottom)
            make.right.equalTo(-50)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.right.equalTo(0)
            make.width.equalTo(16 * 3)
            make.height.equalToSuperview()
        }
        
        loadData()
    }
    
    func loadData() {
        messageLabel.text = message.digest()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
