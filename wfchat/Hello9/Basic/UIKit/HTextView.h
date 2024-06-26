//
//  HTextView.h
//  Hello9
//
//  Created by Ada on 2024/6/26.
//
//  带有占位功能的textview
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTextView : UITextView

@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) UIColor *placeholderTextColor;
@property (nonatomic, copy, nullable)  NSAttributedString *placeholderAttributedText;

@end

NS_ASSUME_NONNULL_END
