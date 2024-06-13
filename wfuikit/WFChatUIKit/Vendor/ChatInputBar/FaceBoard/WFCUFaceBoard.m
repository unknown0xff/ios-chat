//
//  FaceBoard.m
//
//  Created by blue on 12-9-26.
//  Copyright (c) 2012年 blue. All rights reserved.
//  Email - 360511404@qq.com
//  http://github.com/bluemood

#import "WFCUFaceBoard.h"

#import "WFCUStickerItem.h"
#import "YLImageView.h"
#import "YLGIFImage.h"
#import "WFCUFaceButton.h"
#import "WFCUConfigManager.h"
#import "WFCUImage.h"
#import "WFCUUtilities.h"
#import "UIColor+YH.h"

#define FACE_COUNT_ROW  4
#define FACE_COUNT_CLU  7
#define FACE_COUNT_PAGE ( FACE_COUNT_ROW * FACE_COUNT_CLU - 1)
#define FACE_ICON_SIZE  44

#define STICKER_COUNT_ROW  2
#define STICKER_COUNT_CLU  4
#define STICKER_COUNT_PAGE ( STICKER_COUNT_ROW * STICKER_COUNT_CLU)
#define STICKER_ICON_SIZE  80


@interface WFCUFaceBoard() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>
@property(nonatomic, strong) NSArray *faceEmojiArray;
@property(nonatomic, strong) UIView *tabbarView;
@property(nonatomic, strong) UIButton *sendBtn;
@property(nonatomic, strong) UIPageControl *facePageControl;
@property(nonatomic, strong) UICollectionView *collectionView;

@property(nonatomic, strong) UICollectionView *tabView;

@property(nonatomic, strong) NSMutableDictionary<NSString *, WFCUStickerItem *> *stickers;
@property(nonatomic, strong) NSMutableArray<NSString*> *gifs;
@property(nonatomic, strong) NSMutableArray<NSString*> *tie;

@property(nonatomic, assign) NSInteger selectedTableRow;
@end

#define EMOJ_TAB_HEIGHT 47
#define EMOJ_FACE_VIEW_HEIGHT 190

#define EMOJ_AREA_HEIGHT (EMOJ_TAB_HEIGHT + EMOJ_FACE_VIEW_HEIGHT)
@implementation WFCUFaceBoard{
    int width;
    int location;
}

@synthesize delegate;
+ (NSString *)getStickerCachePath {
    NSArray * LibraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [[LibraryPaths objectAtIndex:0] stringByAppendingFormat:@"/Caches/Patch/"];
}

+ (NSString *)getStickerBundleName {
    NSString * bundleName = @"Stickers.bundle";
    return bundleName;
}

+ (void)load {
    [WFCUFaceBoard initStickers];
}

+ (void)initStickers {
    NSString * bundleName = [WFCUFaceBoard getStickerBundleName];
    NSError * err = nil;
    NSFileManager * defaultManager = [NSFileManager defaultManager];
    
    
    NSString * cacheBundleDir = [WFCUFaceBoard getStickerCachePath];
    NSLog(@"缓存资源目录: %@", cacheBundleDir);
    
    
    if (![defaultManager fileExistsAtPath:cacheBundleDir]) {
        [defaultManager createDirectoryAtPath:cacheBundleDir withIntermediateDirectories:YES attributes:nil error: &err];
        
        if(err){
            NSLog(@"初始化目录出错:%@", err);
            return;
        }
    }
    NSString * defaultBundlePath = [[NSBundle bundleForClass:[self class]].resourcePath stringByAppendingPathComponent: bundleName];
    
    NSString * cacheBundlePath = [cacheBundleDir stringByAppendingPathComponent:bundleName];
    if (![defaultManager fileExistsAtPath:cacheBundlePath]) {
        [defaultManager copyItemAtPath: defaultBundlePath toPath:cacheBundlePath error: &err];
        if(err){
            NSLog(@"复制初始资源文件出错:%@", err);
        }
    }
}

- (void)loadGifs {
    self.gifs = [NSMutableArray array];
    NSString *stickerPath = [[WFCUFaceBoard getStickerCachePath] stringByAppendingPathComponent:[WFCUFaceBoard getStickerBundleName]];
    
    NSError * err = nil;
    NSFileManager * defaultManager = [NSFileManager defaultManager];
    NSArray *paths = [defaultManager contentsOfDirectoryAtPath:stickerPath error:&err];
    if (err != nil) {
        NSLog(@"error:%@", err);
        return;
    }
    
    for (NSString *file in paths) {
        BOOL isDir = false;
        NSString *absfile = [stickerPath stringByAppendingPathComponent:file];
        if ([defaultManager fileExistsAtPath:absfile isDirectory:&isDir]) {
            if (!isDir) {
                NSString *name = [[file lastPathComponent] stringByDeletingPathExtension];
                NSString *stickerSubPath = [stickerPath stringByAppendingPathComponent:name];
                if ([defaultManager fileExistsAtPath:stickerSubPath isDirectory:&isDir]) {
                    if (isDir) {
                        NSArray *paths = [defaultManager contentsOfDirectoryAtPath:stickerSubPath error:&err];
                        if (err != nil) {
                            NSLog(@"error:%@", err);
                            return;
                        }
                        for (NSString *p in paths) {
                            NSString *stickerabsfile = [stickerSubPath stringByAppendingPathComponent:p];
                            if ([defaultManager fileExistsAtPath:stickerabsfile isDirectory:&isDir]) {
                                if (!isDir) {
                                    [self.gifs addObject:stickerabsfile];
                                }
                            }
                        }
                    }
                }
            } else {
                NSLog(@"is dir %@", absfile);
            }
        }
    }
}

- (void)loadEmoji {
    NSString *resourcePath = [[NSBundle bundleForClass:[self class]] resourcePath];
    NSString *bundlePath = [resourcePath stringByAppendingPathComponent:@"Emoj.plist"];
    self.faceEmojiArray = [[NSArray alloc]initWithContentsOfFile:bundlePath];
}

- (id)init {
    width = [UIScreen mainScreen].bounds.size.width;
    self = [super initWithFrame:CGRectMake(0, 0, width, EMOJ_AREA_HEIGHT + [WFCUUtilities wf_safeDistanceBottom])];
    self.tie = [NSMutableArray array];
    [self loadGifs];
    [self loadEmoji];
    if (self) {
        self.selectedTableRow = 0;
        
        self.backgroundColor = [UIColor colorWithHexString:@"0xfbfbfd"];
        [self addSubview:self.collectionView];

        self.tabbarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - EMOJ_TAB_HEIGHT - [WFCUUtilities wf_safeDistanceBottom], self.frame.size.width, EMOJ_TAB_HEIGHT + [WFCUUtilities wf_safeDistanceBottom])];
        self.tabbarView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.tabbarView];
        
        [self.tabView setAllowsMultipleSelection:NO];
        self.tabView.allowsSelection = YES;
        [self.tabbarView addSubview:self.tabView];
        
        [self.collectionView reloadData];
    }

    return self;
}

- (void)setSelectedTableRow:(NSInteger)selectedTableRow {
    _selectedTableRow = selectedTableRow;
    [self.tabView reloadData];
}

- (UICollectionView *)tabView {
    if (!_tabView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 15;
        
        _tabView = [[UICollectionView alloc] initWithFrame:CGRectMake((UIScreen.mainScreen.bounds.size.width - 236) / 2, 10, 236, 28) collectionViewLayout:layout];
        _tabView.delegate = self;
        _tabView.dataSource = self;
        _tabView.scrollEnabled = NO;
        _tabView.backgroundColor = [UIColor whiteColor];
        _tabView.showsHorizontalScrollIndicator = NO;
        _tabView.userInteractionEnabled = YES;
        [_tabView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellId"];
    }
    return _tabView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.sectionInset = UIEdgeInsetsMake(8, 16, 8, 16);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        CGRect frame = self.bounds;
        frame.size.height = EMOJ_FACE_VIEW_HEIGHT;
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellId"];
    }
    return _collectionView;
}

- (void)sendBtnHandle:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didTouchSendEmoj)]) {
        [self.delegate didTouchSendEmoj];
    }
}

- (void)faceButton:(UIButton *)sender {
    if ([delegate respondsToSelector:@selector(didTouchEmoj:)]) {
        [delegate didTouchEmoj:self.faceEmojiArray[sender.tag]];
    }
}

- (void)backFace{
    if ([delegate respondsToSelector:@selector(didTouchBackEmoj)]) {
        [delegate didTouchBackEmoj];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.tabView) {
        self.selectedTableRow = indexPath.item;
        [self.collectionView reloadData];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.collectionView) {
        if (self.selectedTableRow == 0) {
            return self.gifs.count;
        } else if (self.selectedTableRow == 1) {
            return self.tie.count;
        } else {
            return self.faceEmojiArray.count;
        }
    } else {
        return 3;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.collectionView) {
        if (self.selectedTableRow == 0) {
            CGFloat width = floorf((UIScreen.mainScreen.bounds.size.width - 32) / 3.0);
            return CGSizeMake(width, width);
        } else if (self.selectedTableRow == 1) {
            CGFloat width = floorf((UIScreen.mainScreen.bounds.size.width - 32) / 4.0);
            return CGSizeMake(width, width);
        } else {
            CGFloat width = 27 + 8;
            CGFloat height = 27 + 6;
            return CGSizeMake(width, height);
        }
    } else {
        if (indexPath.row == 0) {
            return CGSizeMake(92, 28);
        } else if (indexPath.row == 1) {
            return CGSizeMake(53, 28);
        } else {
            return CGSizeMake(53, 28);
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    
    for (UIView *subView in [cell subviews]) {
        [subView removeFromSuperview];
    }
    
    if (collectionView == self.collectionView) {
        if (self.selectedTableRow == 0) {
            CGFloat width = floorf((collectionView.frame.size.width - 32) / 3.0);
            UIImageView *imageView;
            NSString *path = self.gifs[indexPath.item];
            if ([[path pathExtension] isEqualToString:@"gif"]) {
                imageView = [[YLImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
                imageView.image = [YLGIFImage imageWithContentsOfFile:path];
            } else {
                imageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, width, width)];
                imageView.image = [UIImage imageWithContentsOfFile:path];
            }
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapSticker:)]];
            imageView.userInteractionEnabled = YES;
            imageView.tag = indexPath.item;
            [cell addSubview:imageView];
        } else if (self.selectedTableRow == 1) {
            // TODO:
        } else {
            UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
            faceButton.tag = indexPath.item;
            [faceButton addTarget:self action:@selector(faceButton:) forControlEvents:UIControlEventTouchUpInside];
            faceButton.frame = CGRectMake( 0, 0, 26, 26);
            faceButton.titleLabel.font = [UIFont systemFontOfSize:20];
            [faceButton setTitle:self.faceEmojiArray[indexPath.item] forState:UIControlStateNormal];
            [cell addSubview:faceButton];
        }
    } else {
        
        UILabel *label = [[UILabel alloc]init];
        label.textAlignment = NSTextAlignmentCenter;
        
        if (indexPath.row == self.selectedTableRow) {
            label.backgroundColor = [UIColor colorWithHexString:@"0xD7D9D8"];
            label.layer.cornerRadius = 13;
            label.layer.masksToBounds = YES;
            label.textColor = [UIColor colorWithHexString:@"0x4D5461"];
            label.font = [UIFont boldSystemFontOfSize: 15];
        } else {
            label.backgroundColor = [UIColor whiteColor];
            label.layer.cornerRadius = 13;
            label.layer.masksToBounds = YES;
            label.textColor = [UIColor colorWithHexString:@"0x848D99"];
            label.font = [UIFont systemFontOfSize: 15];
        }
        
        if (indexPath.row == 0) {
            label.text = @"GIF动态图";
        } else if (indexPath.row == 1) {
            label.text = @"贴纸";
        } else {
            label.text = @"表情";
        }
        [label sizeToFit];
        CGRect frame = label.frame;
        frame.size.width += 22;
        frame.size.height = 28;
        label.frame = frame;
        
        [cell addSubview:label];
    }
    return cell;
}

- (void)onTapSticker:(UITapGestureRecognizer *)sender {
    UIView *view = sender.view;
    long tag = view.tag;
    NSString *selectSticker = self.gifs[tag];
    if ([self.delegate respondsToSelector:@selector(didSelectedSticker:)]) {
        [self.delegate didSelectedSticker:selectSticker];
    }
}
@end
