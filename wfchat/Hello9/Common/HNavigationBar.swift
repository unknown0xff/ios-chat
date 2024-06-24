//
//  HNavigationBar.swift
//  hello9
//
//  Created by Ada on 6/7/24.
//  Copyright © 2024 hello9. All rights reserved.
//

class HNavigationBar: UIView {
    
    static let height = 100.0
    
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
    
    init(blurEffectStyle: UIBlurEffect.Style? = nil) {
        self.blurEffectStyle = blurEffectStyle
        super.init(frame: .zero)
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
        var appearnce = UINavigationBarAppearance()
        appearnce.configureWithTransparentBackground()
        appearnce.backgroundEffect = nil
        bar.standardAppearance = appearnce
        return bar
    }()
    
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
    
    func reloadBlurStyle() {
        if let style = self.blurEffectStyle {
            let effect = UIBlurEffect(style: style)
            visualEffectView.effect = effect
        } else {
            visualEffectView.effect = nil
        }
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let _ = superview else { return }
        
        addSubview(visualEffectView)
        
        contentView.addSubview(bar)
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        addSubview(contentView)
        
        snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(HNavigationBar.height)
        }
        
        bar.snp.makeConstraints { make in
            make.width.left.centerY.equalToSuperview()
        }
        
        visualEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
