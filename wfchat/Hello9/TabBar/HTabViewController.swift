//
//  HTabViewController.swift
//  ios-hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import UIKit

enum HTabTag: Int {
    case message = 0
    case node = 1
    case mine = 2
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
        
        let messageVC = HChatListViewController()
        messageVC.hidesBottomBarWhenPushed = false
        let messageNav = HNavigationController(rootViewController: messageVC)
        let messageItem = UITabBarItem(title: L10n.message, image: Images.tab_message_off, selectedImage: Images.tab_message_on)
        messageItem.tag = HTabTag.message.rawValue
        
        messageNav.tabBarItem = messageItem
        addChild(messageNav)
        
        self.messageNavationController = messageNav
        
        let node = HNodeHomeViewController()
        node.hidesBottomBarWhenPushed = false
        let nodeNav = HNavigationController(rootViewController: node)
        let nodeItem = UITabBarItem(title: L10n.node, image: Images.tab_node_off, selectedImage: Images.tab_node_on)
        nodeItem.tag = HTabTag.node.rawValue
        nodeNav.tabBarItem = nodeItem
        addChild(nodeNav)
        
        let mineVC = HMineViewController()
        mineVC.hidesBottomBarWhenPushed = false
        let mineNav = HNavigationController(rootViewController: mineVC)
        let mineItem = UITabBarItem(title: L10n.setting, image: Images.tab_setting_off, selectedImage: Images.tab_setting_on)
        mineItem.tag = HTabTag.mine.rawValue
        mineNav.tabBarItem = mineItem
        addChild(mineNav)
        self.mineNavationController = mineNav
    }
    
    func updateMessageBadgeValue(_ number: Int32) {
        let badgeValue: String?
        if number > 0 {
            badgeValue = "\(number)"
        } else {
            badgeValue = nil
        }
        messageNavationController?.tabBarItem.badgeValue = badgeValue
        
    }
}

// MARK: - UITabBarDelegate
extension HTabViewController {
    open override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        selectedIndex = customTabBar.selectedIndex
    }
}
