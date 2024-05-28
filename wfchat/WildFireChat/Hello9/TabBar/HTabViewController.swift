//
//  HTabViewController.swift
//  ios-hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import UIKit
import SnapKit

enum HTabTag: Int {
    case message = 0
    case mine = 1
}

class HTabViewController: UITabBarController {
    
    weak var messageNavationController: HNavigationController?
    weak var mineNavationController: HNavigationController?
    
    lazy var customTabBar = HTabBar()
    
    override var selectedIndex: Int {
        didSet {
            if selectedIndex != customTabBar.selectedIndex {
                customTabBar.selectedIndex = selectedIndex
            }
            if let controllers = viewControllers, selectedIndex < controllers.count {
                delegate?.tabBarController?(self, didSelect: controllers[selectedIndex])
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setValue(customTabBar, forKey: "tabBar")
        addChildControllers()
    }
    
    func addChildControllers() {
        
        let messageVC = WFCUConversationTableViewController()
        messageVC.hidesBottomBarWhenPushed = false
        let messageNav = HNavigationController(rootViewController: messageVC)
        let messageItem = UITabBarItem(title: nil, image: Images.tab_message_off, selectedImage: Images.tab_message_on)
        messageItem.tag = HTabTag.message.rawValue
        messageItem.badgeValue = "+99"
        
        messageNav.tabBarItem = messageItem
        addChild(messageNav)
        
        self.messageNavationController = messageNav
        
        let mineVC = HBasicViewController()
        mineVC.hidesBottomBarWhenPushed = false
        let mineNav = HNavigationController(rootViewController: mineVC)
        let mineItem = UITabBarItem(title: nil, image: Images.tab_mine_off, selectedImage: Images.tab_mine_on)
        mineItem.tag = HTabTag.mine.rawValue
        mineNav.tabBarItem = mineItem
        addChild(mineNav)
        self.mineNavationController = mineNav
    }
    
}

// MARK: - UITabBarDelegate
extension HTabViewController {
    open override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        selectedIndex = customTabBar.selectedIndex
    }
}
