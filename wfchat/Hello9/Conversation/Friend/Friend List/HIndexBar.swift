//
//  HIndexBar.swift
//  Hello9
//
//  Created by Ada on 6/17/24.
//  Copyright © 2024 Hello9. All rights reserved.
//

import UIKit
import Combine

class HIndexBar : UIView {
    
    var currentIndex: Int = 0 {
        willSet {
            (stackView.viewWithTag(currentIndex) as? HIndexBarItem)?.setHighlighted(false)
        }
        didSet {
            (stackView.viewWithTag(currentIndex) as? HIndexBarItem)?.setHighlighted(true)
        }
    }
    
    @Published private(set) var currentTouchIndex: Int = 0
    
    var titles: [String] = [] {
        didSet {
            stackView.arrangedSubviews.forEach { view in
                view.removeFromSuperview()
            }
            titles.enumerated().forEach { title in
                let item = HIndexBarItem(index: title.0, title: title.1)
                item.setHighlighted(title.0 == currentIndex)
                currentSelectView = item
                stackView.addArrangedSubview(item)
            }
        }
    }
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.tag = 8848
        return stack
    }()
    
    lazy var highLightView = UIView()
    
    var currentSelectView: HIndexBarItem!
    
}
extension HIndexBar {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchpoint = touch.location(in: self)
            for sub in stackView.subviews where sub is HIndexBarItem {
                let poinf = sub.layer.convert(touchpoint , from: stackView.layer)
                if sub.layer.contains(poinf) {
                    currentSelectView = sub as? HIndexBarItem
                    showBigHighlightedView()
                    currentTouchIndex = sub.tag
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesBegan(touches, with: event)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        hiddenBigHighlightedView()
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded(touches, with: event)
    }
}

// MARK: - Public Method
extension HIndexBar {

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let _ = superview else {
            return
        }
        addChildren()
        makeConstraints()
    }
}

// MARK: - Private Method
private extension HIndexBar {
    func showBigHighlightedView() {
    }
    
    func hiddenBigHighlightedView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            UIView.animate(withDuration: 0.25) {
                self.highLightView.alpha = 0
            }
        }
    }
    
    func addChildren() {
        addSubview(stackView)
        addSubview(highLightView)
        highLightView.alpha = 0
    }
    
    func makeConstraints() {
        stackView
            .snp
            .makeConstraints { make in
                make.top.equalToSuperview()
                make.center.equalToSuperview()
                make.width.equalToSuperview()
            }
        highLightView
            .snp
            .makeConstraints { make in
                make.right.equalTo(self.snp.left)
                    .offset(-32)
                make.centerY.equalToSuperview()
                make.size.equalTo(60)
            }
    }
}

// MARK: - Properties
class HIndexBarItem : UIView {
    var index: Int = 0
    var title: String = ""
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.font = .boldSystemFont(ofSize: 11)
        lab.textColor = Colors.themeBlack
        lab.numberOfLines = 0
        lab.textAlignment = .center
        return lab
    }()
    convenience init(index: Int, title: String) {
        self.init()
        self.index = index
        self.title = title
        if title.count > 1 {
            let titleArray = Array(title).map({String($0)})
            let newTitle = titleArray.joined(separator: "\n")
            self.titleLabel.text = newTitle
        } else {
            self.titleLabel.text = title
        }
        self.tag = index
    }
    
}

// MARK: - Public Method
extension HIndexBarItem {

    func setHighlighted(_ highlighted: Bool) {
        titleLabel.font = highlighted ? .system11.bold : .system11.bold
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let _ = superview else {
            return
        }
        addChildren()
        makeConstraints()
    }
}

// MARK: - Private Method
private extension HIndexBarItem {
    
    func addChildren() {
        addSubview(titleLabel)
    }
    
    func makeConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.width.equalTo(13)
            make.centerY.equalToSuperview()
            make.top.equalToSuperview().inset(4)
            make.left.equalTo(4)
            make.right.equalTo(-7)
        }
    }
}
