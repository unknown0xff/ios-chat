//
//  Lottie.swift
//  Hello9
//
//  Created by Ada on 2024/7/2.
//  Copyright © 2024 Hello9. All rights reserved.
//

import Lottie

extension LottieAnimation {
    
    private static var lottieBundle: Bundle {
        let bundle = Bundle.main
        let path = bundle.path(forResource: "HLottie", ofType: "bundle")
        let lottieBundle = Bundle(path: path ?? "") ?? .main
        return lottieBundle
    }
    
    static var nodeShakeAnimation: LottieAnimation? {
        LottieAnimation.named("node_shake", bundle: .main)
    }
    
}
