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
    static func show(
        on view: UIView,
        text: String,
        animated: Bool = true,
        afterDelay: TimeInterval? = nil
    ) -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: view, animated: animated)
        hud.label.text = text
        hud.mode = .text
        hud.show(animated: animated)
        if let afterDelay {
            hud.hide(animated: animated, afterDelay: afterDelay)
        }
        return hud
    }
    
    @discardableResult
    static func showAutoHidden(
        on view: UIView,
        text: String,
        afterDelay: TimeInterval = 1.0
    ) -> MBProgressHUD {
        return show(on: view, text: text, afterDelay: afterDelay)
    }
    
}
