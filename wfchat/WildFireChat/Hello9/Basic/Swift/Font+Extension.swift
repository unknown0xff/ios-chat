//
//  Font+Extension.swift
//  ios-hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import Foundation

extension UIFont {
    var bold: UIFont {
        return UIFont(descriptor: fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
    }
    
    var medium: UIFont {
        let fontDescriptor = fontDescriptor.withSymbolicTraits(fontDescriptor.symbolicTraits)!
        let newFontDescriptor = fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.medium
            ]
        ])
        let mediumFont = UIFont(descriptor: newFontDescriptor, size: pointSize)
        return mediumFont
    }
    
    static var system8: UIFont { UIFont.systemFont(ofSize: 8) }
    static var system9: UIFont { UIFont.systemFont(ofSize: 9) }
    static var system10: UIFont { UIFont.systemFont(ofSize: 10) }
    static var system11: UIFont { UIFont.systemFont(ofSize: 11) }
    static var system12: UIFont { UIFont.systemFont(ofSize: 12) }
    static var system13: UIFont { UIFont.systemFont(ofSize: 13) }
    static var system14: UIFont { UIFont.systemFont(ofSize: 14) }
    static var system15: UIFont { UIFont.systemFont(ofSize: 15) }
    static var system16: UIFont { UIFont.systemFont(ofSize: 16) }
    static var system17: UIFont { UIFont.systemFont(ofSize: 17) }
    static var system18: UIFont { UIFont.systemFont(ofSize: 18) }
    static var system19: UIFont { UIFont.systemFont(ofSize: 19) }
    static var system20: UIFont { UIFont.systemFont(ofSize: 20) }
    static var system21: UIFont { UIFont.systemFont(ofSize: 21) }
    static var system22: UIFont { UIFont.systemFont(ofSize: 22) }
    static var system23: UIFont { UIFont.systemFont(ofSize: 23) }
    static var system24: UIFont { UIFont.systemFont(ofSize: 24) }
    static var system25: UIFont { UIFont.systemFont(ofSize: 25) }
    static var system26: UIFont { UIFont.systemFont(ofSize: 26) }
    static var system27: UIFont { UIFont.systemFont(ofSize: 27) }
    static var system28: UIFont { UIFont.systemFont(ofSize: 28) }
    static var system29: UIFont { UIFont.systemFont(ofSize: 29) }
    static var system30: UIFont { UIFont.systemFont(ofSize: 30) }
    static var system31: UIFont { UIFont.systemFont(ofSize: 31) }
    static var system32: UIFont { UIFont.systemFont(ofSize: 32) }
    static var system33: UIFont { UIFont.systemFont(ofSize: 33) }
    static var system34: UIFont { UIFont.systemFont(ofSize: 34) }
    static var system35: UIFont { UIFont.systemFont(ofSize: 35) }
    static var system36: UIFont { UIFont.systemFont(ofSize: 36) }
    static var system37: UIFont { UIFont.systemFont(ofSize: 37) }
    static var system38: UIFont { UIFont.systemFont(ofSize: 38) }
    static var system39: UIFont { UIFont.systemFont(ofSize: 39) }
    static var system40: UIFont { UIFont.systemFont(ofSize: 40) }
    static var system41: UIFont { UIFont.systemFont(ofSize: 41) }
    static var system42: UIFont { UIFont.systemFont(ofSize: 42) }
    static var system43: UIFont { UIFont.systemFont(ofSize: 43) }
    static var system44: UIFont { UIFont.systemFont(ofSize: 44) }
    static var system45: UIFont { UIFont.systemFont(ofSize: 45) }
    static var system46: UIFont { UIFont.systemFont(ofSize: 46) }
    static var system47: UIFont { UIFont.systemFont(ofSize: 47) }
    static var system48: UIFont { UIFont.systemFont(ofSize: 48) }
    static var system49: UIFont { UIFont.systemFont(ofSize: 49) }
    static var system50: UIFont { UIFont.systemFont(ofSize: 50) }
}
