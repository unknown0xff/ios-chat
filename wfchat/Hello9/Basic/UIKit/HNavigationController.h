//
//  HNavigationController.h
//  ios-hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HNavigationController : UINavigationController

@end


/// 导航栏相关协议
@protocol HNavigationBarTransitionDelegate <NSObject>

@optional

/// 是否隐藏导航栏，若未实现，则不隐藏
- (BOOL)prefersNavigationBarHidden;

@end

