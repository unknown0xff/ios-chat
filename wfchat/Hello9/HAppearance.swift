//
//  HAppearance.swift
//  ios-hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

struct HAppearance {
    
    private init() { }
    
    static func install() {
        
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().barStyle = .default
        UINavigationBar.appearance().backIndicatorImage = Images.icon_arrow_back_outline
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundImage = UIImage.image(withColor: Colors.white.withAlphaComponent(0.99))
        navBarAppearance.shadowImage = nil
        navBarAppearance.setBackIndicatorImage(Images.icon_arrow_back_outline, transitionMaskImage: Images.icon_arrow_back_outline)
        navBarAppearance.backButtonAppearance.normal.titlePositionAdjustment = .init(horizontal: -1000, vertical: 0)
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: Colors.themeGray5,
            .font: UIFont.system16.bold
        ]
        
        let normal: [NSAttributedString.Key : Any] = [
            .foregroundColor: Colors.themeBlue1,
            .font: UIFont.system16
        ]
        let disableNormal: [NSAttributedString.Key : Any] = [
            .foregroundColor: Colors.themeBlue1.withAlphaComponent(0.618),
            .font: UIFont.system16
        ]
        
        let done: [NSAttributedString.Key : Any] = [
            .foregroundColor: Colors.themeBlue1,
            .font: UIFont.system16.bold
        ]
        let disableDone: [NSAttributedString.Key : Any] = [
            .foregroundColor: Colors.themeBlue1.withAlphaComponent(0.618),
            .font: UIFont.system16.bold
        ]
        
        let barButtonItemAppearance = UIBarButtonItemAppearance(style: .plain)
        barButtonItemAppearance.normal.titleTextAttributes = normal
        barButtonItemAppearance.disabled.titleTextAttributes = disableNormal
        barButtonItemAppearance.highlighted.titleTextAttributes = disableNormal
        
        let doneButtonItemAppearance = UIBarButtonItemAppearance(style: .done)
        doneButtonItemAppearance.normal.titleTextAttributes = done
        doneButtonItemAppearance.disabled.titleTextAttributes = disableDone
        doneButtonItemAppearance.highlighted.titleTextAttributes = disableDone
        
        navBarAppearance.buttonAppearance = barButtonItemAppearance
        navBarAppearance.doneButtonAppearance = doneButtonItemAppearance
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        
        UITableView.appearance().separatorColor = Colors.themeSeperatorColor
        // UITabBar
        UITabBarItem.appearance().badgeColor = Colors.red01
        
        UITextField.appearance().tintColor = Colors.themeBlue1
        UITextView.appearance().tintColor = Colors.themeBlue1
        
        WFCUConfigManager.global().naviBackgroudColor = Colors.white
    }
    
}
