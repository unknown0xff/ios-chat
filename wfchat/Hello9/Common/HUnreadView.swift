//
//  HUnreadView.swift
//  Hello9
//
//  Created by Ada on 6/8/24.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HUnreadView: UIView {
    
    enum Style {
        case gray
        case red
    }
    
    private lazy var backgroundView: UIImageView = UIImageView(image: Images.icon_unread_background)
    
    private lazy var unreadLabel: UILabel = {
        let label = UILabel()
        label.font = .system10.medium
        label.textColor = Colors.white
        label.textAlignment = .center
        return label
    }()
    
    var style: Style = .red {
        didSet {
            switch style {
            case .red:
                backgroundView.image = Images.icon_unread_background
            case .gray:
                backgroundView.image = nil
                backgroundView.backgroundColor = Colors.themeGray4
            }
        }
    }
    
    var unreadCount: Int32 = 0 {
        didSet {
            if unreadCount <= 0 {
            } else {
                unreadLabel.text = "\(unreadCount)"
            }
        }
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubview(unreadLabel)
        unreadLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        }
        
        snp.makeConstraints { make in
            make.height.equalTo(18)
        }
        
        layer.borderColor = Colors.white.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 9
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
