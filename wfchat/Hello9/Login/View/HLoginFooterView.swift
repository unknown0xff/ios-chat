//
//  HLoginFooterView.swift
//  Hello9
//
//  Created by Ada on 6/7/24.
//  Copyright © 2024 Hello9. All rights reserved.
//

import Foundation

class HLoginFooterView: UIView {
    
    var title: String {
        didSet {
            updateButtonTitle()
        }
    }
    var subTitle: String {
        didSet {
            updateButtonTitle()
        }
    }
    
    private(set) lazy var actionButton: UIButton = {
        let btn = UIButton(type: .custom)
        return btn
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        
        let leftLine = UILabel()
        leftLine.backgroundColor = Colors.themeGray4Background
        view.addSubview(leftLine)
        
        let or = UILabel()
        or.textColor = Colors.themeButtonDisable
        or.text = "OR"
        view.addSubview(or)
        
        let rightLine = UILabel()
        rightLine.backgroundColor = Colors.themeGray4Background
        view.addSubview(rightLine)
        
        or.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.centerX.equalToSuperview()
            make.height.equalTo(22)
        }
        
        leftLine.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(or.snp.left).offset(-16)
            make.height.equalTo(1)
            make.centerY.equalTo(or)
        }
        
        rightLine.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.left.equalTo(or.snp.right).offset(16)
            make.height.equalTo(1)
            make.centerY.equalTo(or)
        }
        
        view.addSubview(actionButton)
        actionButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(or.snp.bottom).offset(30)
            make.height.equalTo(26)
            make.bottom.equalTo(-30)
        }
        
        return view
    }()
    
    init(frame: CGRect = .zero, title: String = "", subTitle: String = "去登录") {
        self.title = title
        self.subTitle = subTitle
        
        super.init(frame: frame)
        
        updateButtonTitle()
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateButtonTitle() {
        actionButton.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    private var attributedTitle: NSAttributedString {
        let attr = NSMutableAttributedString(string: "")
        
        let attr1 = NSAttributedString(string: title, attributes: [
            .font : UIFont.system16,
            .foregroundColor : Colors.themeGray2
        ])
        let attr2 = NSAttributedString(string: subTitle, attributes: [
            .font : UIFont.system16.bold,
            .foregroundColor : Colors.black
        ])
        attr.append(attr1)
        attr.append(attr2)
        
        return attr
    }
}

