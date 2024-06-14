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
