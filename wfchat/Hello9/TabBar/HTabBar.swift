//
//  HTabBar.swift
//  ios-hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import UIKit
import SnapKit

class HTabBar: UITabBar {
    
    static let barContentHeight = 58.0
    static let barHeight = barContentHeight + HUIConfigure.safeBottomMargin
    
    var selectedIndex: Int {
        didSet {
            itemViews.forEach { itemView in
                itemView.isSelected = itemView.barItem.tag == selectedIndex
            }
        }
    }
    
    private lazy var content: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        return stack
    }()
    
    private var itemViews = [HTabBarItemView]()
    
    override func setItems(_ items: [UITabBarItem]?, animated: Bool) {
        let subviews = content.arrangedSubviews
        subviews.forEach { $0.removeFromSuperview() }
        itemViews = []
        
        guard let items, !items.isEmpty else {
            return
        }
        
        for (_, item) in items.enumerated() {
            let itemView = HTabBarItemView(barItem: item)
            content.addArrangedSubview(itemView)
            itemView.snp.makeConstraints { make in
                make.height.equalTo(Self.barContentHeight)
            }
            itemView.addTarget(self, action: #selector(didClickBarItemView(_:)), for: .touchUpInside)
            itemView.isSelected = item.tag == selectedIndex
            itemView.showRightLine = false
            itemViews.append(itemView)
        }
        
    }
    
    override init(frame: CGRect) {
        selectedIndex = 0
        
        super.init(frame: frame)
        
        addChildren()
        makeConstraints()
        
        backgroundColor = Colors.white
        
        layer.shadowColor = Colors.themeBlack.withAlphaComponent(0.0392).cgColor
        layer.shadowOffset = CGSize(width: 0, height: -1)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 24
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = Self.barHeight
        return sizeThatFits
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        removeOriginView()
    }
    
    private func addChildren() {
        addSubview(content)
    }
    
    private func makeConstraints() {
        content.snp.makeConstraints { make in
            make.height.equalTo(Self.barContentHeight)
            make.top.equalTo(0)
            make.width.equalToSuperview()
        }
    }
    
    private func removeOriginView() {
        subviews.forEach { view in
            if view != content {
                view.removeFromSuperview()
            }
        }
    }
    
    @objc func didClickBarItemView(_ sender: HTabBarItemView) {
        selectedIndex = sender.barItem.tag
        delegate?.tabBar?(self, didSelect: sender.barItem)
    }
}
