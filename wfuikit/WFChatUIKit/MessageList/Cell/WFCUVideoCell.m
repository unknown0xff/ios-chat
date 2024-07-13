//
//  VideoCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/2.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUVideoCell.h"
#import <WFChatClient/WFCChatClient.h>
#import "WFCUImage.h"
#import "UIColor+YH.h"

@interface WFCUVideoCell ()
@property(nonatomic, strong) UIImageView *shadowMaskView;
@end

@implementation WFCUVideoCell

+ (CGSize)sizeForClientArea:(WFCUMessageModel *)msgModel withViewWidth:(CGFloat)width {
    WFCCVideoMessageContent *imgContent = (WFCCVideoMessageContent *)msgModel.message.content;
    CGSize size = imgContent.thumbnail.size;
    CGFloat imageWidth = MIN((size.width > size.height) ? 160 : 100, size.width);
    CGFloat imageHeight = imageWidth / (size.width / size.height) ;
    return CGSizeMake(imageWidth, imageHeight);
}

- (void)setModel:(WFCUMessageModel *)model {
    [super setModel:model];
    
    WFCCVideoMessageContent *imgContent = (WFCCVideoMessageContent *)model.message.content;
    CGSize size = [WFCUVideoCell sizeForClientArea:model withViewWidth:120];
    self.thumbnailView.frame = CGRectMake((self.bubbleView.frame.size.width - size.width), (self.bubbleView.frame.size.height - size.height) / 2.0, size.width, size.height);
    self.thumbnailView.image = imgContent.thumbnail;
    self.videoCoverView.frame = CGRectMake(
        (CGRectGetMidX(self.thumbnailView.frame) - 20),
        (CGRectGetMidY(self.thumbnailView.frame) - 20),
        40, 40);
    self.videoCoverView.image = [WFCUImage imageNamed:@"icon_play"];
    
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
        _thumbnailView.layer.cornerRadius = 12;
        _thumbnailView.layer.masksToBounds = YES;
        [self.bubbleView insertSubview:_thumbnailView atIndex:0];
    }
    return _thumbnailView;
}

- (UIImageView *)videoCoverView {
    if (!_videoCoverView) {
        _videoCoverView = [[UIImageView alloc] init];
        _videoCoverView.backgroundColor = [UIColor clearColor];
        [self.bubbleView addSubview:_videoCoverView];
    }
    return _videoCoverView;
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
