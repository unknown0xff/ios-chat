//
//  VoiceCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/9.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUVoiceCell.h"
#import <WFChatClient/WFCChatClient.h>
#import "WFCUImage.h"
#import "UIColor+YH.h"

#define Play_Button_Size 32

@interface WFCUVoiceCell ()
@property(nonatomic, strong) NSTimer *animationTimer;
@property(nonatomic) int animationIndex;
@property(nonatomic, strong) UIButton *playButton;
@end

@implementation WFCUVoiceCell
+ (CGSize)sizeForClientArea:(WFCUMessageModel *)msgModel withViewWidth:(CGFloat)width {
    if (msgModel.showNameLabel) {
        return CGSizeMake(156, 74);
    } else {
        return CGSizeMake(156, 55);
    }
}

- (CGFloat)nameLabelLeft {
    return 21;
}

- (void)setModel:(WFCUMessageModel *)model {
    [super setModel:model];
    
    CGRect bubbleViewFrame = self.bubbleView.frame;
    CGSize dateSize = self.dateLabel.frame.size;
    
    
    if (model.message.direction == MessageDirection_Send) {
        self.playButton.backgroundColor = [UIColor colorWithHexString:@"0x326C1C"];
        self.playButton.frame = CGRectMake(
            CGRectGetMaxX(self.bubbleView.bounds) - 16 - Play_Button_Size,
            10, Play_Button_Size, Play_Button_Size);
        
        self.voiceBtn.frame = CGRectMake(
             CGRectGetMinX(self.playButton.frame) - 8 - 111,
             CGRectGetMinY(self.playButton.frame), 111, 17);
        
        self.durationLabel.frame = CGRectMake(
              CGRectGetMinX(self.playButton.frame) - 8 - 111,
              CGRectGetMaxY(self.voiceBtn.frame), 111, 19);
        self.durationLabel.textAlignment = NSTextAlignmentRight;
        
        CGFloat l = CGRectGetMinX(self.voiceBtn.frame) ;
        CGFloat t = bubbleViewFrame.size.height - 8 - dateSize.height - 5;
        self.dateLabel.frame = CGRectMake(l, t, dateSize.width, dateSize.height);
    } else {
        
        CGFloat l = bubbleViewFrame.size.width - dateSize.width - 18;
        CGFloat t = bubbleViewFrame.size.height - 8 - dateSize.height - 5;
        self.dateLabel.frame = CGRectMake(l, t, dateSize.width, dateSize.height);
        
        self.playButton.backgroundColor = [UIColor colorWithHexString:@"0x0075FF"];
        
        if (model.showNameLabel) {
            self.playButton.frame = CGRectMake(21, 19 + 16, Play_Button_Size, Play_Button_Size);
        } else {
            self.playButton.frame = CGRectMake(21, 10, Play_Button_Size, Play_Button_Size);
        }
        
        self.voiceBtn.frame = CGRectMake(
             CGRectGetMaxX(self.playButton.frame) + 8,
             CGRectGetMinY(self.playButton.frame), 111, 17);
        
        self.durationLabel.frame = CGRectMake(
              CGRectGetMinX(self.voiceBtn.frame),
              CGRectGetMaxY(self.voiceBtn.frame), 111, 19);
        self.durationLabel.textAlignment = NSTextAlignmentLeft;
    }
   
    WFCCSoundMessageContent *soundContent = (WFCCSoundMessageContent *)model.message.content;
    
    NSInteger min = soundContent.duration / 60;
    NSInteger sec = soundContent.duration - min * 60;
    self.durationLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", min, sec];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startAnimationTimer) name:kVoiceMessageStartPlaying object:@(model.message.messageId)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimationTimer) name:kVoiceMessagePlayStoped object:nil];
    if (model.voicePlaying) {
        [self startAnimationTimer];
    } else {
        [self stopAnimationTimer];
    }
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [[UIButton alloc] init];
        _playButton.backgroundColor = [UIColor colorWithHexString:@"0x0075FF"];
        _playButton.layer.cornerRadius = Play_Button_Size / 2.0;
        _playButton.adjustsImageWhenHighlighted = NO;
        [_playButton setImage:[WFCUImage imageNamed:@"voice_stop"] forState:UIControlStateNormal];
        [self.bubbleView addSubview:_playButton];
    }
    return _playButton;
}

- (UIImageView *)voiceBtn {
    if (!_voiceBtn) {
        _voiceBtn = [[UIImageView alloc] init];
        [self.bubbleView addSubview:_voiceBtn];
    }
    return _voiceBtn;
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.font = [UIFont systemFontOfSize:12];
        _durationLabel.textColor = [UIColor colorWithHexString:@"0x808793"];
        _durationLabel.textAlignment = NSTextAlignmentLeft;
        [self.bubbleView addSubview:_durationLabel];
    }
    return _durationLabel;
}

- (void)startAnimationTimer {
    [self stopAnimationTimer];
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                           target:self
                                                         selector:@selector(scheduleAnimation:)
                                                         userInfo:nil
                                                          repeats:YES];
    [self.animationTimer fire];
    [self.playButton setImage: [WFCUImage imageNamed:@"voice_stop"] forState:UIControlStateNormal];
}


- (void)scheduleAnimation:(id)sender {
    NSString *_playingImg;
    
    if (MessageDirection_Send == self.model.message.direction) {
        _playingImg = [NSString stringWithFormat:@"sent_voice_%d", (self.animationIndex++ % 3) + 1];
    } else {
        _playingImg = [NSString stringWithFormat:@"received_voice_%d", (self.animationIndex++ % 3) + 1];
    }

    [self.voiceBtn setImage:[WFCUImage imageNamed:_playingImg]];
}

- (void)stopAnimationTimer {
    if (self.animationTimer && [self.animationTimer isValid]) {
        [self.animationTimer invalidate];
        self.animationTimer = nil;
        self.animationIndex = 0;
    }
    [self.playButton setImage: [WFCUImage imageNamed:@"voice_play"] forState:UIControlStateNormal];
    if (self.model.message.direction == MessageDirection_Send) {
        [self.voiceBtn setImage:[WFCUImage imageNamed:@"sent_voice"]];
    } else {
        [self.voiceBtn setImage:[WFCUImage imageNamed:@"received_voice"]];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
