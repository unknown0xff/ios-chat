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
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundImage = UIImage()
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        
        UITableView.appearance().separatorColor = Colors.themeSeperatorColor
        // UITabBar
        UITabBarItem.appearance().badgeColor = Colors.red01
    }
    
}
