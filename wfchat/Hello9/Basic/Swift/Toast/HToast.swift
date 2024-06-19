//
//  HToast.swift
//  ios-hello9
//
//  Created by Ada on 5/29/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import Foundation
import MBProgressHUD

enum HToast {
    
    @discardableResult
    static func showTipAutoHidden(
        text: String,
        icon: UIImage = Images.icon_logo,
        animated: Bool = true
    ) -> MBProgressHUD?  {
        return showTip(text: text, icon: icon, afterDelay: 2, animated: animated)
    }
    
    @discardableResult
    static func showTip(
        text: String,
        icon: UIImage = Images.icon_logo,
        afterDelay: TimeInterval? = nil,
        animated: Bool = true
    ) -> MBProgressHUD? {
        
        guard let view = UIViewController.h_top?.view else {
            return nil
        }
        
        let placeHolderView = UIView()
        placeHolderView.backgroundColor = .clear
        view.addSubview(placeHolderView)
        placeHolderView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(85)
        }
        
        let hud = MBProgressHUD.showAdded(to: placeHolderView, animated: animated)
        let customView = HCustomToastView()
       
        customView.tipsLabel.text = text
        customView.icon.image = icon
        hud.customView = customView
        hud.backgroundColor = .clear
        hud.mode = .customView
        hud.bezelView.style = .solidColor
        hud.bezelView.color = .clear
        hud.backgroundView.style = .solidColor
        hud.backgroundView.color = .clear
        hud.offset = CGPoint(x: 0, y: 1)
        hud.completionBlock = { [weak placeHolderView] in
            placeHolderView?.removeFromSuperview()
        }
        hud.show(animated: animated)
        
        if let afterDelay {
            hud.hide(animated: animated, afterDelay: afterDelay)
        }
        return hud
    }
    
    @discardableResult
    static func showUndoMode(
        _ text: String,
        remainingTime: Int = 5,
        animated: Bool = true,
        onCountdownFinished: (() -> Void)? = nil,
        onCancelled: (() -> Void)? = nil
    ) -> MBProgressHUD? {
        
        guard let view = UIViewController.h_top?.view else {
            return nil
        }
        
        let placeHolderView = UIView()
        view.addSubview(placeHolderView)
        placeHolderView.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
            make.height.equalTo(85 + HUIConfigure.safeBottomMargin)
        }
        
        let hud = MBProgressHUD.showAdded(to: placeHolderView, animated: true)
        let customView = HCustomToastView(frame: .zero, remainingTime: remainingTime)
        customView.onCountdownFinished = { [weak hud] in
            if let onCountdownFinished {
                onCountdownFinished()
            }
            hud?.hide(animated: animated)
        }
        customView.onCancelled = { [weak hud] in
            if let onCancelled {
                onCancelled()
            }
            hud?.hide(animated: animated)
        }
        customView.tipsLabel.text = text
        hud.customView = customView
        hud.backgroundColor = .clear
        hud.bezelView.style = .solidColor
        hud.bezelView.color = .clear
        hud.backgroundView.style = .solidColor
        hud.backgroundView.color = .clear
        hud.mode = .customView
        hud.offset = CGPoint(x: 0, y: 1)
        hud.completionBlock = { [weak placeHolderView] in
            placeHolderView?.removeFromSuperview()
        }
        hud.show(animated: animated)
        return hud
    }
   
    @discardableResult
    static func showLoading(
        _ text: String = "加载中...",
        animated: Bool = true,
        afterDelay: TimeInterval? = nil
    ) -> MBProgressHUD? {
        guard let view = UIViewController.h_top?.view else {
            return nil
        }
        let hud = MBProgressHUD.showAdded(to: view, animated: animated)
        hud.label.text = text
        hud.mode = .indeterminate
        hud.show(animated: animated)
        if let afterDelay {
            hud.hide(animated: animated, afterDelay: afterDelay)
        }
        return hud
    }
}
