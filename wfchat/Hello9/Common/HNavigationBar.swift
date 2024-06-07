//
//  HNavigationBar.swift
//  hello9
//
//  Created by Ada on 6/7/24.
//  Copyright © 2024 hello9. All rights reserved.
//

class HNavigationBar: UIView {
    
    static let height = 100.0
    
    private var contentView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private(set) lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Images.icon_arrow_back_outline, for: .normal)
        return button
    }()
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let _ = superview else { return }
        
        contentView.addSubview(backButton)
        addSubview(contentView)
        
        snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(HNavigationBar.height)
        }
        
        contentView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        
        backButton.snp.makeConstraints { make in
            make.left.equalTo(22)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }
    
}
