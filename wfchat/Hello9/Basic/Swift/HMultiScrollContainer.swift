//
//  HMultiScrollContainer.swift
//  ios-hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import Foundation
import UIKit

open class HMultiScrollContainer: UIScrollView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 在某些情况下，contentView中的点击事件会被panGestureRecognizer拦截，导致不能响应，
        // 这里设置cancelsTouchesInView表示不拦截
        // panGestureRecognizer.cancelsTouchesInView = false
        
        if #available(iOS 13.0, *) {
            automaticallyAdjustsScrollIndicatorInsets = false
        }
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        } else {
        
        }
        delegate = self
        showsVerticalScrollIndicator = false
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // scroller最大偏移量（最多只能滑动多少）
    @objc public var maxContentOffset: CGFloat = 0.0
    
    // 是否能滑动/或者正在滑动 超过了 maxContentOffset 就不能滑动
    @objc public private(set) var isScrolling: Bool = true {
        didSet {
            if isScrolling == oldValue {
                return
            }
            updateSubScollViewsState()
        }
    }
    
    @objc public var subScrollViews: [UIScrollView] = [UIScrollView]() {
        willSet{
            subScrollViews.forEach {
                $0.removeObserver(self, forKeyPath: kObserveKeyPath)
            }
        }
        didSet {
            subScrollViews.forEach {
                $0.addObserver(self, forKeyPath: kObserveKeyPath, options: .new, context: nil)
                $0.scrollsToTop = false
                if #available(iOS 11.0, *) {
                    $0.contentInsetAdjustmentBehavior = .never
                } else {
                
                }
            }
        }
    }
    
    public func addScrollView(_ scrollView : UIScrollView){
        if subScrollViews.contains(scrollView) {return}
        subScrollViews.append(scrollView)
    }
    
    /// 强制滑动到顶部(子scrollView位置也会复原)
    public func forceScrollToTop() {
        isScrolling = true
        setContentOffset(.zero, animated: true)
    }
        
    deinit {
        subScrollViews.forEach { $0.removeObserver(self, forKeyPath: kObserveKeyPath) }
    }
}

//MARK: - UIGestureRecognizerDelegate

extension HMultiScrollContainer : UIGestureRecognizerDelegate {
    
    /// 返回true表示可以继续传递触摸事件，这样两个嵌套的scrollView才能同时滚动
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let view = otherGestureRecognizer.view as? UIScrollView {
            return subScrollViews.contains(view)
        }
        return false
    }
}

//MARK: - Observer

extension HMultiScrollContainer {
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let newValue = change?[.newKey] as? CGPoint else {
            return
        }
        
        guard let scrollView = object as? UIScrollView else {
            return
        }
        
        // 只有在拖动的时候才考虑设置
        // 当点击某个单元格，push到另一个页面时，也会触发该监听，
        // 同时offset被置为0了，导致自动滚到顶部，因此要添加该判断
        if !scrollView.isDragging {
            return
        }
        
        if isScrolling && maxContentOffset > contentOffset.y {
            // 先移除一下监听，contentOffset被设置时也会调用监听，导致重复调用
            // 虽然可以使用 ‘scrollView.setContentOffset(.zero, animated: false)’ 保证不被重复监听，但是滑动效果不顺畅
            scrollView.removeObserver(self, forKeyPath: kObserveKeyPath)
            scrollView.contentOffset = .zero
            scrollView.addObserver(self, forKeyPath: kObserveKeyPath, options: .new, context: nil)
            return
        }
        if  newValue.y <= 0 {
            isScrolling = true
        } else {
            isScrolling = false
        }
        
    }
    
    fileprivate func updateSubScollViewsState() -> Void {
        subScrollViews.forEach { scrollView in
            if isScrolling {
                scrollView.setContentOffset(.zero, animated: false)
            }
            scrollView.showsVerticalScrollIndicator = !isScrolling
        }
    }
}

extension HMultiScrollContainer : UIScrollViewDelegate {
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if  (scrollView.contentOffset.y > maxContentOffset) ||
            (scrollView.contentOffset.y < maxContentOffset && !isScrolling) {
            scrollView.contentOffset = CGPoint(x: 0, y: maxContentOffset)
        }
    }
}

fileprivate var kObserveKeyPath = "contentOffset"
fileprivate var kOffsetContext = "content_offset_context"
