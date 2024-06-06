//
//  HBasicViewController.h
//  ios-hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//
//  基础控制器
//

#import <UIKit/UIKit.h>
#import "HNavigationController.h"

NS_ASSUME_NONNULL_BEGIN


@interface HBasicViewController : UIViewController <HNavigationBarTransitionDelegate>

/// 导航栏返回按钮图片配置,如果需要隐藏返回按钮，图片设置为nil
@property (nonatomic, strong, nullable) UIImage *backButtonImage;

/// 是否允许导航手势返回，默认YES
@property (nonatomic, assign) BOOL enableInteractivePopGestureRecognizer;

/// 通用方式打开一个页面
+ (instancetype)showBasicViewController;
- (void)showBasicViewController:(nullable UIViewController *)parentController;
- (void)showBasicViewController:(nullable UIViewController *)parentController animated:(BOOL)animated;

/// 关闭当前控制器。 如果是push则pop，present则dismiss
- (void)closeViewController;
- (void)closeViewController:(BOOL)animated;

/// 初始化一些数据，禁止使用 self.view
/// 想要添加view，请在customView中重写，或者viewdidload里面
/// 子类重写，请调用super
- (void)didInitialize;

/// 初始化视图，子类需要调用super
- (void)customView;

/// 设置返回按钮，默认导航栏第一个控制器没有返回按钮
/// 返回按钮的图片可全局配置，也可以单独设置
- (void)setupBackButton;

/// 返回按钮点击方法，默认是调用closeViewController
- (IBAction)didClickBackBarButton:(id)sender;

/// 截屏通知，父类不做任何操作
- (void)applicationUserDidTakeScreenshotNotification:(NSNotification *)notification;

/// 动态字体通知
- (void)contentSizeCategoryDidChanged:(NSNotification *)notification;

///是否将该控制器添加到堆栈中,默认YES
- (BOOL)shouldAddToControllerStack;

@end

NS_ASSUME_NONNULL_END
