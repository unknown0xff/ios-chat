//
//  HNavigationBar.swift
//  hello9
//
//  Created by Ada on 6/7/24.
//  Copyright © 2024 hello9. All rights reserved.
//

class HNavigationBar: UIView {
    
    static let height = 100.0
    
    var bottomView: UIView? {
        didSet {
            if let bottomView {
                bottomStack.addArrangedSubview(bottomView)
            } else {
                bottomStack.arrangedSubviews.forEach { v in
                    bottomStack.removeArrangedSubview(v)
                    v.removeFromSuperview()
                }
            }
        }
    }
    
    var blurEffectStyle: UIBlurEffect.Style? {
        didSet {
            reloadBlurStyle()
        }
    }
    
    var leftBarButtonItem: UIBarButtonItem? {
        set {
            navigationItem.leftBarButtonItem = newValue
        }
        get {
            navigationItem.leftBarButtonItem
        }
        
    }

    var rightBarButtonItem: UIBarButtonItem? {
        set {
            navigationItem.rightBarButtonItem = newValue
        }
        get {
            navigationItem.rightBarButtonItem
        }
    }
    
    var title: String? {
        set {
            navigationItem.title = newValue
        }
        get {
            navigationItem.title
        }
    }
    
    private lazy var bottomStack: UIStackView = {
        let stack = UIStackView()
        return stack
    }()
    
    init(blurEffectStyle: UIBlurEffect.Style? = nil) {
        self.blurEffectStyle = blurEffectStyle
        
        let frame = CGRectMake(0, 0, UIScreen.width, HNavigationBar.height)
        super.init(frame: frame)
        
        addSubview(visualEffectView)
        contentView.addSubview(bar)
        addSubview(contentView)
        addSubview(bottomStack)
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var visualEffectView: UIVisualEffectView = {
        let effectView = UIVisualEffectView()
        return effectView
    }()
    
    private(set) lazy var navigationItem: UINavigationItem = {
        let item = UINavigationItem()
        return item
    }()
    
    private lazy var bar: UINavigationBar = {
        let bar = UINavigationBar()
        bar.items = [self.navigationItem]
        var appearnce = UINavigationBar.appearance().standardAppearance.copy()
        appearnce.configureWithTransparentBackground()
        appearnce.backgroundEffect = nil
        bar.standardAppearance = appearnce
        return bar
    }()
    
    private(set) var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    func reloadBlurStyle() {
        if let style = self.blurEffectStyle {
            let effect = UIBlurEffect(style: style)
            visualEffectView.effect = effect
        } else {
            visualEffectView.effect = nil
        }
    }
    
    func makeConstraints() {
        
        bar.snp.makeConstraints { make in
            make.width.left.centerY.equalToSuperview()
        }
        
        visualEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        bottomStack.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(bottomStack.snp.top)
            make.height.equalTo(56)
        }
    }
    
}
