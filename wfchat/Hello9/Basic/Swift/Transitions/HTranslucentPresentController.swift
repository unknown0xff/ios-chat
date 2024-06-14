
import Foundation
import UIKit

open class HTranslucentPresentController: UIPresentationController {
    
    private(set) public lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        return view
    }()
    
    open override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        containerView?.addSubview(backgroundView)
        
        presentingViewController.beginAppearanceTransition(false, animated: true)
        
        backgroundView.alpha = 0
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { (context :UIViewControllerTransitionCoordinatorContext) in
            self.backgroundView.alpha = 1
        }, completion: { (context :UIViewControllerTransitionCoordinatorContext) in })
    }
    
    open override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        presentingViewController.endAppearanceTransition()
        
        if !completed {
            backgroundView.removeFromSuperview()
        }
    }
    
    open override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
       
        presentingViewController.beginAppearanceTransition(true, animated: true)
        
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { (context :UIViewControllerTransitionCoordinatorContext) in
            self.backgroundView.alpha = 0
        }, completion: { (context :UIViewControllerTransitionCoordinatorContext) in
        })
    }
    
    open override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        
        presentingViewController.endAppearanceTransition()
        
        if completed {
            backgroundView.removeFromSuperview()
        }
    }
    
    open override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        if let container = containerView {
            backgroundView.frame = container.bounds
        }
    }
}
