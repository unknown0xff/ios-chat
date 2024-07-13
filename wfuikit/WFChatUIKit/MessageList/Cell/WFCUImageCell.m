//
//  ImageCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/2.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUImageCell.h"
#import <WFChatClient/WFCChatClient.h>
#import <SDWebImage/SDWebImage.h>
#import "UIColor+YH.h"

@interface WFCUImageCell ()
@property(nonatomic, strong) UIImageView *shadowMaskView;
@end

@implementation WFCUImageCell

+ (CGSize)sizeForClientArea:(WFCUMessageModel *)msgModel withViewWidth:(CGFloat)width {
    WFCCImageMessageContent *imgContent = (WFCCImageMessageContent *)msgModel.message.content;
    CGSize size = CGSizeMake(130, 130);
    if(imgContent.thumbnail) {
        size = imgContent.thumbnail.size;
    } else {
        size = [WFCCUtilities imageScaleSize:imgContent.size targetSize:CGSizeMake(240, 240) thumbnailPoint:nil];
    }
    
    CGFloat scale = size.width / size.height;
    
    CGFloat maxWidth = (size.width > size.height) ? 130 : 100;
    size.width = MIN(size.width, maxWidth);
    size.height = size.width / scale;

    return size;
}

- (void)setModel:(WFCUMessageModel *)model {
    [super setModel:model];
    
    WFCCImageMessageContent *imgContent = (WFCCImageMessageContent *)model.message.content;
    CGSize size = [WFCUImageCell sizeForClientArea:model withViewWidth:120];
    self.thumbnailView.frame = CGRectMake((self.bubbleView.frame.size.width - size.width), (self.bubbleView.frame.size.height - size.height) / 2.0, size.width, size.height);
    if (!imgContent.thumbnail && imgContent.thumbParameter) {
        [self.thumbnailView sd_setImageWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"%@?%@", imgContent.remoteUrl, imgContent.thumbParameter] stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]]]];
    } else {
        self.thumbnailView.image = imgContent.thumbnail;
    }
    
    self.dateLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.dateLabel.layer.cornerRadius = 6;
    self.dateLabel.layer.masksToBounds = YES;
    
    CGRect dateLabelFrame = self.dateLabel.frame;
    self.dateLabel.frame = 
    CGRectMake(
       CGRectGetMaxX(self.thumbnailView.frame) - dateLabelFrame.size.width - 8,
       CGRectGetMaxY(self.thumbnailView.frame) - dateLabelFrame.size.height - 8,
       dateLabelFrame.size.width,
       dateLabelFrame.size.height
    );
    self.dateLabel.textColor = [UIColor colorWithHexString:@"0xF7F9FC"];
    self.bubbleView.image = nil;
}

- (UIImageView *)thumbnailView {
    if (!_thumbnailView) {
        _thumbnailView = [[UIImageView alloc] init];
        [self.bubbleView insertSubview:_thumbnailView atIndex:0];
        _thumbnailView.layer.cornerRadius = 16;
        _thumbnailView.layer.masksToBounds = YES;
        _thumbnailView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _thumbnailView;
}

- (void)setMaskImage:(UIImage *)maskImage{
    [super setMaskImage:maskImage];
    if (_shadowMaskView) {
        [_shadowMaskView removeFromSuperview];
    }
    _shadowMaskView = [[UIImageView alloc] initWithImage:maskImage];
    
    CGRect frame = CGRectMake(self.bubbleView.frame.origin.x - 1, self.bubbleView.frame.origin.y - 1, self.bubbleView.frame.size.width + 2, self.bubbleView.frame.size.height + 2);
    _shadowMaskView.frame = frame;
    [self.contentView addSubview:_shadowMaskView];
    [self.contentView bringSubviewToFront:self.bubbleView];
    
}

- (UIView *)getProgressParentView {
    return self.thumbnailView;
}
@end
