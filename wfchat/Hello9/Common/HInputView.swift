//
//  HInputView.swift
//  Hello9
//
//  Created by Ada on 2024/7/16.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HInputView: UIView {
    
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system14
        label.textColor = Colors.themeGray2
        return label
    }()
    
    private lazy var stack: UIStackView = {
        let s = UIStackView()
        s.alignment = .center
        s.distribution = .fill
        s.backgroundColor = Colors.grayF6
        s.layer.cornerRadius = 16
        return s
    }()
    
    private(set) lazy var textField: UITextField = {
        let field = UITextField.default
        return field
    }()
    
    private(set) lazy var leftIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    
    private(set) lazy var rightButton: UIButton = {
        let btn = UIButton(type: .system)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureSubviews() {
        addSubview(titleLabel)
        addSubview(stack)
        
        stack.addArrangedSubview(leftIcon)
        
        let space = UIView()
        space.backgroundColor = Colors.grayD1
        stack.addArrangedSubview(space)
        space.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(16)
        }
        
        stack.setCustomSpacing(12, after: space)
        stack.addArrangedSubview(textField)
        stack.addArrangedSubview(rightButton)
        
        rightButton.addTarget(self, action: #selector(didClickRightButton(_:)), for: .touchUpInside)
    }
    
    private func makeConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.top.equalTo(0)
            make.right.equalTo(-16)
            make.height.equalTo(22)
        }
        
        stack.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.left)
            make.right.equalTo(-30)
            make.height.equalTo(54)
            make.bottom.equalTo(0)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        leftIcon.snp.makeConstraints { make in
            make.width.equalTo(57)
            make.height.equalTo(42)
        }
        
        rightButton.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalToSuperview()
        }
    }
    
    @objc func didClickRightButton(_ sender: UIButton) {
        
        // isSecureTextEntry.toggle()
    }
    
}
