//
//  Created by xianda.yang on 2022/4/9.
//

import Foundation
import UIKit

extension HModalPresentNavigationController {
    public enum Style : Int {
        case actionSheet = 0    // 系统action sheet
        case alert = 1          // 类系统alert
        case alpha = 2          // alpha 渐变
    }
}

open class HModalPresentNavigationController: HNavigationController {
    
    private(set) public weak var rootViewController: UIViewController?
    
    // 背景色
    public var translucentColor: UIColor?
    
    // 背景点击回调
    // 仅当 automaticallyDismissWhenTouchBackground = true 才有效
    public var backgroundClickCompletion: (() -> Void)? = nil
    
    // 点击背景是否自动消失
    public var automaticallyDismissWhenTouchBackground: Bool = true
    
    // alert 还是 action
    public var preferredStyle: HModalPresentNavigationController.Style = .alert
    
    // 转场动画，如果自定义，则忽略 preferredStyle的设置
    public var dismissAnimatedTransitioning: UIViewControllerAnimatedTransitioning?
    public var presentAnimatedTransitioning: UIViewControllerAnimatedTransitioning?
 
    open override var modalPresentationStyle: UIModalPresentationStyle {
        get { .custom }
        set { super.modalPresentationStyle = newValue }
    }
    
    open func didInitialize() {
        transitioningDelegate = self
        modalPresentationCapturesStatusBarAppearance = true
        providesPresentationContextTransitionStyle = true
        definesPresentationContext = true
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configure()
    }
    
    public override required init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        configure(rootViewController: rootViewController)
    }
    
    public required init(rootViewController: UIViewController,
                            translucentColor: UIColor? = nil,
                            automaticallyDismiss: Bool = true,
                            preferredStyle: HModalPresentNavigationController.Style = .alert) {
        super.init(rootViewController: rootViewController)
        configure(rootViewController: rootViewController, translucentColor: translucentColor, automaticallyDismiss: automaticallyDismiss, preferredStyle: preferredStyle)
    }
    
    public required init(rootView: UIView,
                            translucentColor: UIColor? = nil,
                            automaticallyDismiss: Bool = true,
                            preferredStyle: HModalPresentNavigationController.Style = .alert) {
        
        let rootVC = HModalPresentRootViewController.init()
        rootVC.view.addSubview(rootView)
        if preferredStyle == .alert {
            rootView.center = rootVC.view.center
        }
        super.init(rootViewController: rootVC)
        configure(rootViewController: rootVC, translucentColor: translucentColor, automaticallyDismiss: automaticallyDismiss, preferredStyle: preferredStyle)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if touches.first?.view == rootViewController?.view {
            if automaticallyDismissWhenTouchBackground {
                if children.count <= 1 {
                    dismiss(animated: true, completion: backgroundClickCompletion)
                }
            }
        }
    }
    
    open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        rootViewController?.dismiss(animated: flag, completion: completion)
    }
   
    @discardableResult
    open class func show(root: UIViewController,
                         presenting: UIViewController? = UIViewController.h_top,
                         translucentColor: UIColor? = nil,
                         automaticallyDismiss: Bool = true,
                         preferredStyle: HModalPresentNavigationController.Style = .actionSheet,
                         completion: (() -> Void)? = nil) -> Self {
        let nav = Self.init(rootViewController: root, translucentColor: translucentColor, automaticallyDismiss: automaticallyDismiss, preferredStyle: preferredStyle)
        presenting?.present(nav, animated: true, completion: completion)
        return nav
    }
    
    @discardableResult
    open class func show(rootView: UIView,
                         presenting: UIViewController? = UIViewController.h_top,
                         translucentColor: UIColor? = nil ,
                         automaticallyDismiss: Bool = true,
                         preferredStyle: HModalPresentNavigationController.Style = .actionSheet,
                         completion: (() -> Void)? = nil) -> Self {
        let nav = Self.init(rootView: rootView, translucentColor: translucentColor, automaticallyDismiss: automaticallyDismiss, preferredStyle: preferredStyle)
        presenting?.present(nav, animated: true, completion: completion)
        return nav
    }
    
    private func configure(rootViewController: UIViewController? = nil,
             translucentColor: UIColor? = nil,
             automaticallyDismiss: Bool = true,
             preferredStyle: HModalPresentNavigationController.Style = .alert) {
        didInitialize()
        self.rootViewController = rootViewController
        self.translucentColor = translucentColor
        self.automaticallyDismissWhenTouchBackground = automaticallyDismiss
        self.preferredStyle = preferredStyle
    }
    
    
}


//MARK: - UIViewControllerTransitioningDelegate

extension HModalPresentNavigationController: UIViewControllerTransitioningDelegate {
    
    open func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        let presentation = HTranslucentPresentController.init(presentedViewController: presented, presenting: presenting)
        
        if let translucentColor = translucentColor {
            presentation.backgroundView.backgroundColor = translucentColor
        }
        
        return presentation
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let dismiss = dismissAnimatedTransitioning {
            return dismiss
        }
        
        switch preferredStyle {
            case .alert:
                return HAlertTransition(present: false)
            case .alpha:
                return HBasicTransition(present: false)
            case .actionSheet:
                return nil
        }
    }
    
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
       
        if let present = presentAnimatedTransitioning {
            return present
        }
        
        switch preferredStyle {
            case .alert:
                return HAlertTransition(present: true)
            case .alpha:
                return HBasicTransition(present: true)
            case .actionSheet:
                return nil
        }
    }
    
}

//MARK: - HModalPresentRootViewController

open class HModalPresentRootViewController: HBasicViewController {
  
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    
    open override func prefersNavigationBarHidden() -> Bool {
        true
    }
}
