//
//  Created by xianda.yang on 2022/4/10.
//
//  基础 透明动画
//

import Foundation
import UIKit

open class HBasicTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    open var isPresenting : Bool = false
    
    public convenience init(present : Bool) {
        self.init()
        isPresenting = present
    }
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            presentAnimateTransition(using: transitionContext)
        }else{
            dismissAnimateTransition(using: transitionContext)
        }
    }
    
    open func presentAnimateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let toView = transitionContext.viewController(forKey: .to)?.view ?? UIView()
        toView.alpha = 0
        toView.center = transitionContext.containerView.center
        
        transitionContext.containerView.addSubview(toView)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveLinear) {
            toView.alpha = 1.0
        } completion: { (finish : Bool) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    open func dismissAnimateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.viewController(forKey: .from)?.view ?? UIView()

        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveLinear) {
            fromView.alpha = 0
        } completion: { (finish : Bool) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
