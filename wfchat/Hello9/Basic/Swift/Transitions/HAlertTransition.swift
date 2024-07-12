//
//  Created by Ada on 2022/4/5.
//
//  放大缩小动画（类系统alert）
//

import Foundation
import UIKit

open class HAlertTransition: HBasicTransition {
    
    override open func presentAnimateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let toView = transitionContext.viewController(forKey: .to)?.view ?? UIView()
        toView.alpha = 0
        toView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        transitionContext.containerView.addSubview(toView)
        toView.center = transitionContext.containerView.center

        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveLinear) {
            toView.alpha = 1.0
            toView.transform = .identity
        } completion: { (finish : Bool) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

open class HPopTransition: HBasicTransition {
    
    open override func dismissAnimateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        
        let fromView = transitionContext.viewController(forKey: .from)?.view ?? UIView()
        var toFrame = fromView.frame
        toFrame.origin.x = toFrame.width
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .transitionFlipFromTop) {
            fromView.frame = toFrame
        } completion: { (finish : Bool) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

open class HActionSheetTransition: HBasicTransition {
    
    open override func dismissAnimateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        
        let fromView = transitionContext.viewController(forKey: .from)?.view ?? UIView()
        var toFrame = fromView.frame
        toFrame.origin.y = toFrame.height
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .transitionFlipFromTop) {
            fromView.frame = toFrame
        } completion: { (finish : Bool) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    override open func presentAnimateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toView = transitionContext.viewController(forKey: .to)?.view ?? UIView()
        transitionContext.containerView.addSubview(toView)
        let toFrame = toView.frame
        var initFrame = toView.frame
        initFrame.origin.y = initFrame.height
        toView.frame = initFrame
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .transitionFlipFromBottom) {
            toView.frame = toFrame
        } completion: { (finish : Bool) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
