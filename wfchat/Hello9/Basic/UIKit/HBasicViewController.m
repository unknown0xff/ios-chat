//
//  HBasicViewController.m
//  ios-hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

#import <objc/objc.h>
#import <objc/runtime.h>
#import "HBasicViewController.h"
#import "UIViewController+Extention.h"
#import "HNavigationController.h"

@interface HBasicViewController ()<UIGestureRecognizerDelegate>

@end

@implementation HBasicViewController

@synthesize backButtonImage = _backButtonImage;

/// 通用方式打开一个页面
+ (instancetype)showBasicViewController {
    HBasicViewController *ctrl = [[self alloc] init];
    [ctrl showBasicViewController: [UIViewController h_topViewController]];
    return ctrl;
}

- (void)showBasicViewController:(nullable UIViewController *)parentController {
    [self showBasicViewController:parentController animated:YES];
}

- (void)showBasicViewController:(nullable UIViewController *)parentController animated:(BOOL)animated {
    if (parentController == nil) {
        parentController = [UIViewController h_topViewController];
    }
    [parentController.navigationController pushViewController:self animated:animated];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialize];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    
    [self setupBackButtonImage];
    
    self.enableInteractivePopGestureRecognizer = YES;
    self.hidesBottomBarWhenPushed = YES;
    
    // 不管navigationBar的backgroundImage如何设置，都让布局撑到屏幕顶部，方便布局的统一
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    // 截屏通知
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationUserDidTakeScreenshotNotification:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    // 动态字体notification
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(contentSizeCategoryDidChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 内置的HNavigationController已经做好了手势处理
    if ([self.navigationController isKindOfClass:HNavigationController.class]) {
        return;
    }
    // 部分控制是被三方组件push出来的，如果不主动设置是这个手势，无法使用系统自带的侧滑功能
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self setupBackButton];
    [self customView];
}

- (void)dealloc {
    // 移除所有通知接收器 (观察者)
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)customView {
    // 子类重写
}


- (void)setupBackButtonImage {
    if (@available(iOS 11.0,*)) {
        _backButtonImage = UINavigationBar.appearance.backIndicatorImage;
    } else {
        _backButtonImage = [UIBarButtonItem.appearance backButtonBackgroundImageForState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    }
}


- (void)closeViewController {
    [self closeViewController:YES];
}

- (void)closeViewController:(BOOL)animated {
    if (self.navigationController && self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:animated];
    } else {
        [self dismissViewControllerAnimated:animated completion:nil];
    }
}

- (void)setupBackButton {
    if (self.presentingViewController ||
        (self.navigationController && [self.navigationController.viewControllers count] > 1)) {
        if (self.backButtonImage) {
            self.navigationItem.leftBarButtonItem = ({
                UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [customButton addTarget:self action:@selector(didClickBackBarButton:) forControlEvents:UIControlEventTouchUpInside];
                [customButton setImage:self.backButtonImage forState:UIControlStateNormal];
                [customButton sizeToFit];
                UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:customButton];
                backBarButton;
            });
        } else  {
            self.navigationItem.leftBarButtonItem = nil;
        }
    }
}

#pragma mark - Actions

- (IBAction)didClickBackBarButton:(id)sender {
    [self closeViewController];
}

#pragma mark - getter/setter

///是否将该控制器添加到堆栈中,默认YES
- (BOOL)shouldAddToControllerStack {
    return YES;
}

- (void)setBackButtonImage:(UIImage *)backButtonImage {
    _backButtonImage = backButtonImage;
    if (self.isViewLoaded) {
        [self setupBackButton];
    }
}

/// 电池条样式
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

/// 模态弹出视图时默认全屏
- (UIModalPresentationStyle)modalPresentationStyle{
    return UIModalPresentationFullScreen;
}

#pragma mark - HNavigationBarTransitionDelegate

- (BOOL)prefersNavigationBarHidden {
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return self.enableInteractivePopGestureRecognizer &&
            self.navigationController.viewControllers.count > 1;
}

#pragma mark - action/notification

- (void)applicationUserDidTakeScreenshotNotification:(NSNotification *)notification {
    // 子类重写
}

- (void)contentSizeCategoryDidChanged:(NSNotification *)notification {
    // 子类重写
}
@end
