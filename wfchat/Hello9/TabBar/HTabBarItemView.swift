//
//  HTabBarItemView.swift
//  ios-hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import UIKit
import SnapKit

class HTabBarItemView: UIControl {
    
    var barItem: UITabBarItem = .init() {
        didSet {
            bindData()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            bindData()
        }
    }
    
    var showRightLine: Bool = false {
        didSet {
            rightLineView.isHidden = !showRightLine
        }
    }
    
    private var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        return imageView
    }()

    private var badgeContent: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 9
        label.layer.masksToBounds = true
        label.backgroundColor = Colors.red01
        return label
    }()
    
    private var badgeLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.textColor = Colors.white
        label.font = .systemFont(ofSize: 13.0)
        label.textAlignment = .center
        return label
    }()
    
    private var rightLineView: UIView = {
        let line = UIView()
        line.backgroundColor = Colors.gray01
        line.isHidden = true
        return line
    }()
    
    private var badgeValueObservation: NSKeyValueObservation?
    
    init(barItem: UITabBarItem, isSelected: Bool = false) {
        self.barItem = barItem
        super.init(frame: .zero)
        self.isSelected = isSelected
        
        badgeValueObservation = barItem.observe(\.badgeValue) { [weak self] _, _ in
            self?.bindData()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let _ = superview else {
            return
        }
        addChildren()
        makeConstraints()
        bindData()
    }
    
    private func bindData() {
        imageView.image = isSelected ? barItem.selectedImage : barItem.image
        badgeLabel.text = barItem.badgeValue
        badgeContent.isHidden = barItem.badgeValue?.isEmpty ?? true
    }
    
    private func addChildren() {
        addSubview(imageView)
        addSubview(badgeContent)
        badgeContent.addSubview(badgeLabel)
        addSubview(rightLineView)
    }
    
    private func makeConstraints() {
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.center.equalToSuperview()
        }
        
        badgeContent.snp.makeConstraints { make in
            make.height.equalTo(18)
            make.width.lessThanOrEqualTo(100)
            make.width.greaterThanOrEqualTo(18)
            make.top.equalTo(imageView)
            make.left.equalTo(imageView.snp.right).offset(-9)
        }
        
        badgeLabel.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4))
        }
        
        rightLineView.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(24)
            make.centerY.equalToSuperview()
            make.right.equalTo(0)
        }
    }
        
}
