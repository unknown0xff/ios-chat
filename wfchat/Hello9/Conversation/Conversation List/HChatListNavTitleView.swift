//
//  HChatListNavTitleView.swift
//  Hello9
//
//  Created by Ada on 2024/7/12.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HChatListNavTitleView: UIView {
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var showLoading: Bool = false {
        didSet {
            loadingView.isHidden = !showLoading
            if showLoading {
                loadingView.startAnimating()
            }
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        let titleTextAttributes = UINavigationBar.appearance().standardAppearance.titleTextAttributes
        l.textColor = titleTextAttributes[.foregroundColor] as? UIColor
        l.font = titleTextAttributes[.font] as? UIFont
        return l
    }()
    
    private lazy var loadingView: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .medium)
        return v
    }()
    
    private lazy var containtView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 6
        stack.axis = .horizontal
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        containtView.addArrangedSubview(loadingView)
        containtView.addArrangedSubview(titleLabel)
        loadingView.isHidden = true
        addSubview(containtView)
        containtView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
