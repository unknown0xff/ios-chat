//
//  UIViewController+Extention.m
//  ios-hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

#import "UIViewController+Extention.h"

@implementation UIViewController (HExtention)

- (nullable UIViewController *)h_nearbyParentViewController {
    // 先查看是否是子控制器（以view的形式加在控制器上）
    UIViewController *parent = [self parentViewController];
    if (parent == nil) {
        // 如果不是，则查看是否被present出来
        parent = self.presentingViewController;
        
        // 如果导航栏控制器，则用top代替
        if ([parent isKindOfClass:UINavigationController.class]) {
            parent = parent.childViewControllers.lastObject;
        }
    }
    
    return parent;
}

+ (UIViewController *)h_topViewController {
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = UIApplication.sharedApplication.windows;
        for (UIWindow *tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    return [self h_findNextViewController:window.rootViewController];

}

+ (UIViewController *)h_findNextViewController:(UIViewController *)currentViewController {
    while (currentViewController.presentedViewController != nil) {
        currentViewController = currentViewController.presentedViewController;
    }
    if ([currentViewController isKindOfClass:UITabBarController.class]) {
        return [self h_findNextViewController:(((UITabBarController *)currentViewController).selectedViewController)];
    } else if ([currentViewController isKindOfClass:UINavigationController.class]) {
        UINavigationController *nav = (UINavigationController *)currentViewController;
        return [self h_findNextViewController:(nav.viewControllers.lastObject)];
    } else {
        return currentViewController;
    }
}


@end
