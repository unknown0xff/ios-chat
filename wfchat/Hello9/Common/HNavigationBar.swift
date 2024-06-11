//
//  HNavigationBar.swift
//  hello9
//
//  Created by Ada on 6/7/24.
//  Copyright © 2024 hello9. All rights reserved.
//

class HNavigationBar: UIView {
    
    static let height = 100.0
    
    private(set) var contentView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private(set) lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Images.icon_arrow_back_outline, for: .normal)
        return button
    }()
    
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system16.bold
        label.textColor = Colors.themeGray5
        label.textAlignment = .center
        return label
    }()
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let _ = superview else { return }
        
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        addSubview(contentView)
        
        snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(HNavigationBar.height)
        }
        
        contentView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(26)
            make.width.lessThanOrEqualTo(200)
        }
        
        backButton.snp.makeConstraints { make in
            make.left.equalTo(22)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }
    
}
