//
//  HAppDelegate.swift
//  WildFireChat
//
//  Created by Ada on 5/27/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

import Foundation
import UIKit

@main
class HAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IMService.share.wfuConfigureManager.setupNavBar()
        
        if !IMService.share.connectByDefault() {
            let loginVC = WFCLoginViewController()
            loginVC.isPwdLogin = true
            window?.rootViewController = UINavigationController(rootViewController: loginVC)
        } else {
            window?.rootViewController = WFCBaseTabBarController()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        if UIApplication.shared.applicationIconBadgeNumber > 0 {
            UIApplication.shared.applicationIconBadgeNumber = -1
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        return false
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
}
