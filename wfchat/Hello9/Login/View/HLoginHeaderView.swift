//
//  HLoginHeaderView.swift
//  Hello9
//
//  Created by Ada on 6/7/24.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HLoginHeaderView: UIView {
    
    private lazy var logoView: UIImageView = {
        let view = UIImageView()
        view.image = Images.icon_logo42
        return view
    }()
    
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system26.bold
        label.textColor = Colors.black
        return label
    }()
    
    private(set) lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .system14
        label.textColor = Colors.themeGray03
        label.numberOfLines = 2
        label.textAlignment = .justified
        return label
    }()
    
    init(frame: CGRect = .zero, title: String, subTitle: String) {
        super.init(frame: frame)
        titleLabel.text = title
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.14
        subTitleLabel.attributedText = NSMutableAttributedString(string: subTitle, attributes: [.paragraphStyle: paragraphStyle])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let _ = superview else {
            return
        }
        addSubview(logoView)
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        
        logoView.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.top.equalTo(0)
            make.width.equalTo(38)
            make.height.equalTo(42)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(logoView.snp.right).offset(10)
            make.centerY.equalTo(logoView)
            make.width.equalTo(UIScreen.width - 108)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(logoView)
            make.top.equalTo(logoView.snp.bottom).offset(14)
            make.width.equalTo(UIScreen.width - 60)
            make.bottom.equalTo(0)
        }
        
    }
}
