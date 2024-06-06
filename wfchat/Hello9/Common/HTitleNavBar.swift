//
//  HTitleNavBar.swift
//  hello9
//
//  Created by Ada on 5/30/24.
//  Copyright © 2024 hello9. All rights reserved.
//

class HTitleNavBar: UIView {
    
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system18.bold
        label.textColor = Colors.gray03
        return label
    }()
    
    private(set) lazy var bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.black.withAlphaComponent(0.03)
        return view
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(bottomLine)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(24)
            make.bottom.equalTo(-10)
            make.height.equalTo(30)
            make.right.equalTo(-24)
        }
        
        bottomLine.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
