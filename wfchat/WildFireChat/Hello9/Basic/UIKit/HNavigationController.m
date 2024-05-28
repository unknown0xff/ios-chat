//
//  HNavigationController.m
//  ios-hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

#import <objc/objc.h>
#import <objc/runtime.h>

#import "HRuntime.h"
#import "HNavigationController.h"

@interface HNavigationControllerDelegate : NSObject <UINavigationControllerDelegate>

@end

@interface HNavigationController () <UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL isViewControllerPushing;


@end

@implementation HNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.interactivePopGestureRecognizer.delegate = self;
}

- (void)dealloc {
    self.delegate = nil;
}

/**
 *  重新父类方法，目的：在navigationcontroller 正在进行push动作时，
 *  不再继续响应push事件，直到push的viewController 已经显示
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.isViewControllerPushing || !viewController) return;

    if (self.isViewLoaded) {
        if (self.view.window) {
            // 增加 self.view.window 作为判断条件是因为当 UINavigationController 不可见时（例如上面盖着一个 prenset 起来的 vc，或者 nav 所在的 tabBar 切到别的 tab 去了），pushViewController 会被执行，但 navigationController:didShowViewController:animated: 的 delegate 不会被触发，导致 isViewControllerPushing 的标志位无法正确恢复，所以做个保护。
            if (animated) {
                self.isViewControllerPushing = YES;
            }
        }
    }
    self.interactivePopGestureRecognizer.enabled = NO;
    [super pushViewController:viewController animated:animated];
    
    // 某些情况下 push 操作可能会被系统拦截，实际上该 push 并不生效，
    // 这种情况下应当恢复相关标志位，否则会影响后续的 push 操作
    if (![self.viewControllers containsObject:viewController]) {
        self.isViewControllerPushing = NO;
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationFullScreen;
}

#pragma mark - InteractivePopGestureRecognizer
/// 侧滑手势代理
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer  {
    // topVC 根据topvc是否禁用推断是否侧滑
    id<UIGestureRecognizerDelegate> topVC = (id<UIGestureRecognizerDelegate>)self.topViewController;
    if ([topVC respondsToSelector:@selector(gestureRecognizerShouldBegin:)]) {
        BOOL shouldBegin = [topVC gestureRecognizerShouldBegin:gestureRecognizer];
        return shouldBegin;
    }
    // 如果topvc未实现‘gestureRecognizerShouldBegin’
    // 且根视图，就禁止掉右划手势
    return self.viewControllers.count > 1;
}

@end


@implementation HNavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([navigationController isKindOfClass:HNavigationController.class]) {
        ((HNavigationController*)navigationController).isViewControllerPushing = NO;
    }
    
    navigationController.interactivePopGestureRecognizer.enabled = (navigationController.childViewControllers.count > 1);
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController<HNavigationBarTransitionDelegate> *)viewController animated:(BOOL)animated {
    if ([viewController respondsToSelector:@selector(prefersNavigationBarHidden)]) {
        [navigationController setNavigationBarHidden:[viewController prefersNavigationBarHidden] animated:animated];
    }
//    else {
//        [navigationController setNavigationBarHidden:NO animated:animated];
//    }
}

@end




#pragma mark -
/// 导航栏代理，用于控制导航栏的显示与隐藏
@interface UINavigationController (delegate)

@property (nonatomic, strong) HNavigationControllerDelegate *delegator;

@end

@implementation UINavigationController (delegate)



+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        HExchangeImplementations(self.class, @selector(viewDidLoad), @selector(__swiz_viewDidLoad));
    });
}

- (HNavigationControllerDelegate *)delegator {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDelegator:(HNavigationControllerDelegate *)delegator {
    objc_setAssociatedObject(self, @selector(delegator), delegator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)__swiz_viewDidLoad {
    [self __swiz_viewDidLoad];
    
    if (self.delegate == nil) {
        self.delegator = [[HNavigationControllerDelegate alloc] init];
        self.delegate = self.delegator;
    }
}

@end
