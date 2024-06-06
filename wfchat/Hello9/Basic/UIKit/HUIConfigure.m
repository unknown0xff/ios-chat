//
//  HUIConfigure.m
//  hello9
//
//  Created by Ada on 5/30/24.
//  Copyright © 2024 hello9. All rights reserved.
//

#import "HUIConfigure.h"


@implementation HUIConfigure

+ (instancetype)shareInstance {
    static dispatch_once_t pred;
    static HUIConfigure *sharedInstance;
    dispatch_once(&pred, ^{
        sharedInstance = [[HUIConfigure alloc] init];
    });
    return sharedInstance;
}

+ (CGFloat)statusBarHeight {
    
    CGFloat statusBarHeight = 0;
    
    UIWindowScene *windowScene = nil;
    for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive) {
            windowScene = scene;
            break;
        }
    }
    
    if (windowScene) { // 灵动岛设备 如 15pro: statusBar 高度为 54 safeAreaInsets.top 为 59
        statusBarHeight = windowScene.statusBarManager.statusBarFrame.size.height;
    }
    
    if (statusBarHeight <= 0) { // 兜底 理论上不会进
        UIWindowScene *scene = (UIWindowScene *)[UIApplication.sharedApplication.connectedScenes anyObject];
        statusBarHeight = scene.windows.firstObject.safeAreaInsets.top;
    }
    
    
    if (statusBarHeight <= 0) {
        statusBarHeight = [self isIPhone12] ? 50.0f : ([self isIPhoneXSeries] ? 44.0f : 20.0f);
    }
    return statusBarHeight;
}

+ (CGFloat)navigationBarHeight {
    return self.statusBarHeight + 44.0f;
}

+  (CGFloat)tabBarHeight {
    return [self isIPhoneXSeries] ? 84.0f : 50.0f;
}

+  (CGFloat)safeBottomMargin {
    return ([self isIPhoneXSeries] ? 34.0f : 0.0f);
}

+  (CGFloat)lineWidth {
    return 1.0f / UIScreen.mainScreen.scale;
}

+  (CGFloat)toolBarHeight {
    return 44.0f;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initDefaultConfiguration];
    }
    return self;
}

- (void)initDefaultConfiguration {
    
}

+ (BOOL)isIPhone12 {
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return NO;
    }
    
    if (![UIScreen instancesRespondToSelector:@selector(currentMode)]) {
        return NO;
    }
    
    return CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(428, 926)) || CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(926, 428)) || CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(390, 844)) || CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(844, 390)) || CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(360, 780)) || CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(780, 360));
}

+ (BOOL)isIPhoneXSeries {
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return NO;
    }
    
    if (![UIScreen instancesRespondToSelector:@selector(currentMode)]) {
        return NO;
    }
    
    BOOL isIPhoneXSeries = CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(414, 896)) || CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(375, 812)) || CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(896, 414)) || CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(812, 375)) || CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(428, 926)) || CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(926, 428)) || CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(390, 844)) || CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(844, 390)) || CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(360, 780)) || CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(780, 360));
    
    if (!isIPhoneXSeries) {
        isIPhoneXSeries = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;
    }
    return isIPhoneXSeries;
}

@end

