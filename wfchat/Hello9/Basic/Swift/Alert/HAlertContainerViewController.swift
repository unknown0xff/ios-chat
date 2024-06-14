import UIKit

open class HAlertContainerAction: NSObject {

    var handler: ((HAlertContainerAction) -> Void)?
    
    var title: String = ""
    
    public init(title: String, handler: ((HAlertContainerAction) -> Void)? = nil) {
        self.title = title
        self.handler = handler
    }
}

// MARK: - Properties
open class HAlertContainerViewController: HModalPresentRootViewController {
    
    public private(set) var containerView = HAlertContainerView.init()
    
    var leftHandler: HAlertContainerAction?
    var rightHandler: HAlertContainerAction?
    
    @discardableResult
    public class func show(message: String,
                    title: String? = nil,
                    leftHandler: HAlertContainerAction? = nil,
                    rightHandler: HAlertContainerAction? = nil) -> Self {
        return show(message: message, attributeMessage: nil, title: title, leftHandler: leftHandler, rightHandler: rightHandler)
    }
    
    @discardableResult
    public class func show(attributeMessage: NSAttributedString,
                    title: String? = nil,
                    leftHandler: HAlertContainerAction? = nil,
                    rightHandler: HAlertContainerAction? = nil) -> Self {
        return show(message: nil, attributeMessage: attributeMessage, title: title, leftHandler: leftHandler, rightHandler: rightHandler)
    }
    
    @discardableResult
    public class func show(contentView: UIView, title: String? = nil, leftHandler: HAlertContainerAction? = nil, rightHandler: HAlertContainerAction? = nil) -> Self {
        return show(message: nil, attributeMessage: nil, title: title, contentView: contentView, leftHandler: leftHandler, rightHandler: rightHandler)
    }
    
    class func show(message: String?,
                    attributeMessage: NSAttributedString?,
                    title: String?,
                    contentView: UIView? = nil,
                    leftHandler: HAlertContainerAction?,
                    rightHandler: HAlertContainerAction?) -> Self {
        
        let vc = Self.init()
        if leftHandler == nil && rightHandler == nil {
            vc.leftHandler = leftHandler
            vc.rightHandler = rightHandler
            vc.containerView.leftButtonTitle = leftHandler?.title ?? "取消"
            vc.containerView.rightButtonTitle = rightHandler?.title ?? "确定"
        }
        if let leftHandler = leftHandler {
            vc.leftHandler = leftHandler
            vc.containerView.leftButtonTitle = leftHandler.title.isEmpty ? "取消" : leftHandler.title
        }
        if let rightHandler = rightHandler {
            vc.rightHandler = rightHandler
            vc.containerView.rightButtonTitle = rightHandler.title.isEmpty ? "确定" : rightHandler.title
        }
        
        vc.containerView.message = message
        vc.containerView.attributeMessage = attributeMessage
        vc.containerView.title = title
        vc.containerView.customContentView = contentView
        
        HModalPresentNavigationController.show(root: vc, automaticallyDismiss: false, preferredStyle: .alert, completion: nil)
        return vc
    }
    
}

// MARK: - Override
extension HAlertContainerViewController  {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(containerView)
        
        containerView.leftButton.addTarget(self, action: #selector(Self.didClickLeftButton(sender:)), for: .touchUpInside)
        containerView.rightButton.addTarget(self, action: #selector(Self.didClickRightButton(sender:)), for: .touchUpInside)
    }
    
    open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        
        super.dismiss(animated: flag) {
            if completion != nil {
                completion!()
                self.leftHandler = nil
                self.rightHandler = nil
            } else {
                self.leftHandler = nil
                self.rightHandler = nil
            }
        }
    }
    
    @objc func didClickRightButton(sender: UIButton) {
        if let handle = rightHandler?.handler {
            dismiss(animated: true) { handle(self.rightHandler!) }
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc func didClickLeftButton(sender: UIButton) {
        if let handle = leftHandler?.handler {
            dismiss(animated: true) {  handle(self.leftHandler!) }
        } else {
            dismiss(animated: true)
        }
    }
}


// MARK: - Constant
// fileprivate let kConstant = ""
