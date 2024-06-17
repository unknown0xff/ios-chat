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
        
        UINavigationBar.appearance().backIndicatorImage = Images.icon_arrow_back_outline
        UITableView.appearance().separatorColor = Colors.themeSeperatorColor
        // UITabBar
        UITabBarItem.appearance().badgeColor = Colors.red01
    }
    
}
