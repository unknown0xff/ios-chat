//
//  HNestedScrollView.swift
//  Hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//


open class HNestedScrollView: UIScrollView {
    public var allowMutiPanGesture: Bool = false
}

extension HNestedScrollView: UIGestureRecognizerDelegate {
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let gestureView = gestureRecognizer.view else { return true }
       
        guard allowMutiPanGesture else {  return true  }
        
        guard let gesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
     
        let velocityX = gesture.velocity(in: gestureView).x
        
        if velocityX > 0 { // 右滑
            if self.contentOffset.x == 0 {
                return false
            }
        }else if velocityX < 0 {// 左滑
            if self.contentOffset.x + self.frame.size.width == self.contentSize.width {
                return false
            }
        }
        
        return true
    }
}
