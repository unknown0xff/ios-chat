//
//  ImageCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/2.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUStickerCell.h"
#import <WFChatClient/WFCChatClient.h>
#import "WFCUMediaMessageDownloader.h"
#import <SDWebImage/SDWebImage.h>
#import "WFCUUtilities.h"
#import "UIColor+YH.h"

@interface WFCUStickerCell ()
@property (nonatomic, strong)UIImageView *thumbnailView;
@end

@implementation WFCUStickerCell

+ (CGSize)sizeForClientArea:(WFCUMessageModel *)msgModel withViewWidth:(CGFloat)width {
    WFCCStickerMessageContent *imgContent = (WFCCStickerMessageContent *)msgModel.message.content;
    CGSize size = imgContent.size;
    
    if (size.height > width || size.width > width) {
        float scale = MIN(width/size.height, width/size.width);
        size = CGSizeMake(size.width * scale, size.height * scale);
    }
    
    CGFloat aspect = size.width / size.height;
    
    size.width = MIN(UIScreen.mainScreen.bounds.size.width / 2.0, size.width);
    size.height = size.width / aspect;
    
    return size;
}

- (void)superUpdateModel:(WFCUMessageModel *)model {
    [super setModel:model];
}

- (void)setModel:(WFCUMessageModel *)model {
    WFCCStickerMessageContent *stickerMsg = (WFCCStickerMessageContent *)model.message.content;
    if (model.message.conversation.type == SecretChat_Type && model.message.direction == MessageDirection_Receive && model.message.status != Message_Status_Played) {
        [[WFCCIMService sharedWFCIMService] setMediaMessagePlayed:model.message.messageId];
        model.message.status = Message_Status_Played;
    }
    
    __weak typeof(self) weakSelf = self;
    if (!stickerMsg.localPath.length || ![WFCUUtilities isFileExist:stickerMsg.localPath]) {
        BOOL downloading = [[WFCUMediaMessageDownloader sharedDownloader] tryDownload:model.message success:^(long long messageUid, NSString *localPath) {
            if (messageUid == weakSelf.model.message.messageUid) {
                weakSelf.model.mediaDownloading = NO;
                stickerMsg.localPath = localPath;
                [weakSelf setModel:weakSelf.model];
            }
        } error:^(long long messageUid, int error_code) {
            if (messageUid == weakSelf.model.message.messageUid) {
                weakSelf.model.mediaDownloading = NO;
                [weakSelf superUpdateModel:weakSelf.model];
            }
        }];
        if (downloading) {
            model.mediaDownloading = YES;
        }
    } else {
        model.mediaDownloading = NO;
    }
    [super setModel:model];
    
    self.thumbnailView.frame = self.bubbleView.bounds;
    if (stickerMsg.localPath.length && [WFCUUtilities isFileExist:stickerMsg.localPath]) {
        if(model.message.conversation.type == SecretChat_Type && model.message.direction == MessageDirection_Receive) {
            NSData *data = [NSData dataWithContentsOfFile:stickerMsg.localPath];
            data = [[WFCCIMService sharedWFCIMService] decodeSecretChat:model.message.conversation.target mediaData:data];
            self.thumbnailView.image = [UIImage imageWithData:data];
        } else {
            [self.thumbnailView sd_setImageWithURL:[NSURL fileURLWithPath:stickerMsg.localPath]];
        }
    } else {
        self.thumbnailView.image = nil;
    }
    
    self.dateLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.dateLabel.layer.cornerRadius = 6;
    self.dateLabel.layer.masksToBounds = YES;
    self.dateLabel.textColor = [UIColor colorWithHexString:@"0xF7F9FC"];
}

- (UIImageView *)thumbnailView {
    if (!_thumbnailView) {
        _thumbnailView = [[UIImageView alloc] init];
        _thumbnailView.layer.cornerRadius = 16;
        _thumbnailView.layer.masksToBounds = YES;
        [self.bubbleView insertSubview:_thumbnailView atIndex:0];
    }
    return _thumbnailView;
}
@end
