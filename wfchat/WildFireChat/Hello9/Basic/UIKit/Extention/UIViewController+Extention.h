//
//  UIViewController+Extention.h
//  ios-hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (HExtention)

/// 父控制器或者临近的叔伯控制器
@property (nonatomic, readonly, nullable) UIViewController *h_nearbyParentViewController;

/// 顶层控制器
@property (nonatomic, class, nullable, readonly) UIViewController *h_topViewController;

@end

NS_ASSUME_NONNULL_END
