//
//  Layout+Extension.swift
//  ios-hello9
//
//  Created by Ada on 5/29/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import Foundation

extension UIScreen {
    
    static var width: CGFloat {
        UIScreen.main.bounds.width
    }
    
    static var height: CGFloat {
        UIScreen.main.bounds.height
    }
    
}

extension CGFloat {
    
    func multipliedBy(_ amount: CGFloat) -> CGFloat {
        self * amount
    }
}

//MARK:- 键盘监听

extension UIResponder {
    
    @objc func didKeyboadFrameChange(_ keyboardFrame: CGRect, isShow: Bool) {
        
    }
    
    @objc func addObserveKeyboardNotifications() {
        DispatchQueue.main.async {
            NotificationCenter.default.addObserver(self, selector: #selector(UIResponder.keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(UIResponder.keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    
    @objc func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        let info:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        didKeyboadFrameChange(keyboardFrame, isShow: true)
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        didKeyboadFrameChange(CGRect.zero, isShow: false)
    }
    
}

extension UICellAccessory {
    static func image(_ image: UIImage = Images.icon_disclosure_indicator_gray, placement: UICellAccessory.Placement = .trailing()) -> UICellAccessory {
        let imageView = UIImageView(image: image)
        return .customView(configuration: .init(customView: imageView, placement: placement))
    }
}
