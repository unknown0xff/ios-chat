//
//  HUIConfigure.h
//  hello9
//
//  Created by Ada on 5/30/24.
//  Copyright © 2024 hello9. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HUIConfigure : NSObject

+ (instancetype)shareInstance;

/// 系统级别的常量（只读）
@property (nonatomic, assign, readonly, class) CGFloat statusBarHeight;
@property (nonatomic, assign, readonly, class) CGFloat navigationBarHeight;

@property (nonatomic, assign, readonly, class) CGFloat tabBarHeight;
@property (nonatomic, assign, readonly, class) CGFloat safeBottomMargin;
@property (nonatomic, assign, readonly, class) CGFloat toolBarHeight;
@property (nonatomic, assign, readonly, class) CGFloat lineWidth;


@end

NS_ASSUME_NONNULL_END

