//
//  HAppDelegate.swift
//  ios-hello9
//
//  Created by Ada on 5/27/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import Foundation
import UIKit

@main
class HAppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UINavigationBar.appearance().backIndicatorImage = Images.icon_arrow_back_outline

        if !IMService.share.connectByDefault() {
            let loginNav = HLoginNavigationViewController()
            window?.rootViewController = loginNav
        } else {
            window?.rootViewController = HTabViewController()
        }
        
        requestRemoteNotificationsAuthorization(application)
        
        return true
    }

    func requestRemoteNotificationsAuthorization(_ application: UIApplication) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [UNAuthorizationOptions.alert, UNAuthorizationOptions.sound, UNAuthorizationOptions.badge]) { granted, error in
            guard let _ = error else {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
                return
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        if UIApplication.shared.applicationIconBadgeNumber > 0 {
            UIApplication.shared.applicationIconBadgeNumber = -1
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        IMService.share.updateBadgeNumber()
        IMService.share.prepardDataForShareExtension()
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
        let token = (deviceToken as NSData).toHex()
        IMService.share.setDeviceToken(token)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("----------willPresentNotification")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("----------didReceiveNotificationResponse")
        let categoryId = response.notification.request.content.categoryIdentifier
        if categoryId == "categoryIdentifier" {
            if response.actionIdentifier == "enterApp" {
                
            } else {
                print("----------No")
            }
        }
        
        completionHandler()
    }
}
