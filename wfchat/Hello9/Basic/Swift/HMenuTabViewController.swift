//
//  HMenuTabViewController.swift
//  Hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import Foundation
import UIKit

open class HMenuTabViewController: HBasicViewController, UIScrollViewDelegate {
    
    open private(set) lazy var tabView: UIScrollView = {
        let v = UIScrollView.init()
        v.backgroundColor = .white
        v.showsHorizontalScrollIndicator = false
        v.showsVerticalScrollIndicator = false
        v.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        v.delegate = self
        return v
    }()
    
    // 设置不滚动，均匀分布
    open var isScrollEnabled: Bool {
        get { tabView.isScrollEnabled }
        set { tabView.isScrollEnabled = newValue }
    }
    
    open private(set) lazy var animationLineView: UIImageView = {
        let v = UIImageView(image: Images.icon_tab_line)
        v.frame = CGRect(x: 24, y: animationLineViewTop, width: 25, height: 4)
        return v
    }()
    
    open private(set) lazy var bottomLineView: UIView = {
        let v = UIView()
        v.backgroundColor = Colors.themeSeperatorColor
        return v
    }()
    
    open private(set) lazy var containerView: HNestedScrollView = {
        let v = HNestedScrollView()
        v.showsHorizontalScrollIndicator = false
        v.showsVerticalScrollIndicator = false
        v.isPagingEnabled = true
        v.delegate = self
        v.bounces = false
        return v
    }()
    
    open private(set) lazy var tabBar: UIStackView = {
        let stack = UIStackView.init()
        stack.spacing = 0
        stack.alignment = .center
        stack.distribution = .fillEqually
        return stack
    }()
    
    open private(set) lazy var tabButtons: [UIButton] = []
    
    /// tab的高度
    open var tabViewHeight: CGFloat = 50
    /// tab的上边距
    open var topOffset: CGFloat = 0
    /// 每个tabbutton的最大宽度
    open var tabButtonMaxWidth: CGFloat?
    
    open var normalFont: UIFont = .system14
    open var normalColor: UIColor = Colors.themeGray2
    
    open var selectedFont: UIFont = .system14.bold
    open var selectedColor: UIColor = Colors.themeBlack
    
    open var defaultSelectedIndex: Int = 0
    
    open var animationLineViewTop: CGFloat { topOffset + tabViewHeight - 8  }
    
    /// 各子控制器的宽度，默认是屏幕宽度
    open var childViewWidth: CGFloat = UIScreen.width
    
    open var selectedIndex: Int {
        tabButtons.filter { $0.isSelected }.first?.tag ?? 0
    }
    
    private var controllersMap:[ UIButton : UIViewController] = .init()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildren()
        makeConstraints()
    }
    
    open func addController(_ ctrl: UIViewController, title: String) {
        
        let btn = makeTabButton(title)
        btn.tag = tabButtons.count
        tabBar.addArrangedSubview(btn)
        
        // 缓存子控制器，懒加载到视图上
        ctrl.isChildController = true
        controllersMap[btn] = ctrl
        tabButtons.append(btn)
        
        if btn.tag == defaultSelectedIndex {
            selectedItem(btn)
        }
        
        btn.addTarget(self, action: #selector(Self.didSelectedItem(_:)), for: .touchUpInside)
        containerView.contentSize = .init(width: childViewWidth * CGFloat(tabButtons.count), height: 0)
    }
    
    @objc open func clear() {
        tabButtons.forEach {
            $0.removeFromSuperview()
        }
        
        children.forEach { vc in
            if vc.isChildController == true {
                vc.removeFromParent()
                vc.view.removeFromSuperview()
                vc.didMove(toParent: nil)
            }
        }
        
        controllersMap = [:]
        tabButtons.removeAll()
        containerView.contentSize = .zero
    }
    
    @objc open func selected(at index: Int) {
        if index >= tabButtons.count {
            return
        }
        
        didSelectedItem(self.tabButtons[index])
    }
    
    @objc open func didSelectedIndex(_ index: Int) { }
    
    @objc func didSelectedItem(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        tabButtons.filter { $0.isSelected } .forEach { btn in
            self.deselectedItem(btn)
        }
        selectedItem(sender)
    }
    
    func tabViewScrollToIndex() {
        if let selectedButton = tabButtons.filter({ $0.isSelected }).first {
            
            let tabViewContentMaxWidth = tabView.contentSize.width + tabView.contentInset.left + tabView.contentInset.right
            if tabViewContentMaxWidth <= tabView.frame.width {
                return
            }
            
            let frame = tabBar.convert(selectedButton.frame, to: tabView)
            
            let offsetX = (frame.origin.x + frame.size.width)
            if offsetX < (tabView.frame.width * 0.5) {
                tabView.setContentOffset(CGPoint.init(x: -tabView.contentInset.left, y: 0), animated: true)
                return
            }
            
            var dx = frame.origin.x - tabView.frame.width * 0.5 + frame.size.width * 0.5
            dx = max(dx, 0)
            dx = min(dx, tabView.contentSize.width - tabView.frame.width + tabView.contentInset.right)
            tabView.setContentOffset(CGPoint.init(x: dx, y: 0), animated: true)
        }
    }
    
    func selectedItem(_ sender: UIButton, enableScrollContainer: Bool = true) {
        sender.isSelected = true
        sender.titleLabel?.font = selectedFont
        
        if enableScrollContainer {
            let offset = childViewWidth * CGFloat(sender.tag)
            containerView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
        }
        
        if let ctrl = controllersMap[sender] {
            addChild(ctrl)
            ctrl.didMove(toParent: self)
            containerView.addSubview(ctrl.view)
            
            let totalWidth = childViewWidth * CGFloat(sender.tag)
            ctrl.view.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.width.height.equalToSuperview()
                make.left.equalTo( totalWidth )
            }
            
            controllersMap[sender] = nil
        }
        
        tabViewScrollToIndex()
        
        didSelectedIndex(sender.tag)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
            self.updateAnimationLineView()
        })
    }
    
    func deselectedItem(_ sender: UIButton) {
        sender.isSelected = false
        sender.titleLabel?.font = normalFont
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // 顶部tab滚动
        if scrollView == tabView {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                self.updateAnimationLineView(false)
            })
            return
        }
        
        // 底部container滚动
        let offsetX = scrollView.contentOffset.x
        
        let index = Int((offsetX / childViewWidth) + 0.5)
        if index == selectedIndex {
            return
        }
        
        if let btn = tabButtons.filter({ $0.tag == index }).first {
            tabButtons.filter { $0.isSelected }
                .forEach { self.deselectedItem($0) }
            selectedItem(btn, enableScrollContainer: false)
        }
    }
    
    open func makeTabButton(_ title: String) -> UIButton {
        let btn = UIButton.init(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = normalFont
        btn.setTitleColor(normalColor, for: .normal)
        btn.setTitleColor(selectedColor, for: .selected)
        
        if let tabButtonMaxWidth = tabButtonMaxWidth {
            btn.snp.makeConstraints { make in
                make.width.lessThanOrEqualTo(tabButtonMaxWidth)
            }
        }
        return btn
    }
    
    func updateAnimationLineView(_ animate: Bool = true ) {
        if let selectedButton = tabButtons.filter({ $0.isSelected }).first {
            
            var frame = tabBar.convert(selectedButton.frame, to: view)
            
            // 有时候，frame的size为zero，需要手动计算一下
            if frame.size == .zero {
                let label = UILabel()
                label.font = selectedFont
                label.textColor = .clear
                label.text = selectedButton.title(for: .selected)
                label.sizeToFit()
                var size = label.frame.size
                if let tabButtonMaxWidth = tabButtonMaxWidth {
                    size.width = min(tabButtonMaxWidth, size.width)
                }
                frame.size = size
            }
            
            let width: CGFloat = animationLineView.frame.width
            let height: CGFloat = animationLineView.frame.height
            let x = frame.origin.x + (frame.width - width) / 2.0
            let y = animationLineViewTop
            
            if animationLineView.superview == nil {
                animationLineView.frame = CGRect(x: x, y: animationLineViewTop, width: width, height: height)
                view.insertSubview(animationLineView, aboveSubview: tabView)
            } else {
                if animate {
                    UIView.animate(withDuration: 0.3) {
                        self.animationLineView.frame = CGRect(x: x, y: y, width: width, height: height)
                    }
                } else {
                    animationLineView.frame = CGRect(x: x, y: y, width: width, height: height)
                }
                
            }
        }
    }
    
    open func addChildren() {
        
        view.addSubview(tabView)
        
        if isScrollEnabled {
            tabView.addSubview(tabBar)
        } else {
            tabBar.distribution = .fillEqually
            view.addSubview(tabBar)
        }
        
        view.addSubview(bottomLineView)
        view.addSubview(containerView)
    }
    
    open func makeConstraints() {
        
        tabView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(tabViewHeight)
            make.top.equalToSuperview().offset(topOffset)
        }
        
        if isScrollEnabled {
            tabBar.snp.makeConstraints { make in
                make.height.left.right.equalToSuperview()
            }
        } else {
            tabBar.snp.makeConstraints { make in
                make.width.right.left.equalToSuperview()
                make.top.equalTo(tabView)
                make.height.equalTo(tabViewHeight)
            }
        }
        
        bottomLineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(tabView)
            make.height.equalTo(1.0)
        }
        
        containerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(tabView.snp.bottom)
        }
        
    }
}

private var kIsChildController = "HUIKit.kIsChildController"

private extension UIViewController {
    
    var isChildController: Bool? {
        get {
            objc_getAssociatedObject(self, &kIsChildController) as? Bool
        }
        set {
            objc_setAssociatedObject(self, &kIsChildController, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
