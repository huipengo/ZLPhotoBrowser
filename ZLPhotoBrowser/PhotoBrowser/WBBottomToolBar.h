//
//  WBBottomToolBar.h
//  ZLPhotoBrowserFramework
//
//  Created by huipeng on 2020/8/7.
//  Copyright © 2020 long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLPhotoConfiguration.h"
@class ZLImageNavigationController, ZLPhotoModel;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT CGFloat const WBBottomToolBarHeight;

typedef NS_ENUM(NSInteger, WBPhotoBrowserSource) {
    // 缩略图
    WBPhotoBrowserThumbnail = 0,
    // 大图
    WBPhotoBrowserBigImage  = 1
};

typedef void(^WBEditActionCompletion)(id sender);
typedef void(^WBPreviewActionCompletion)(id sender);
typedef void(^WBOriginalPhotoActionCompletion)(id sender);
typedef void(^WBDoneActionCompletion)(id sender);

@interface WBBottomToolBar : UIView

@property (nonatomic, strong) UIButton *editButton;

@property (nonatomic, strong) UIButton *previewButton;

@property (nonatomic, strong) UIButton *originalPhotoButton;

@property (nonatomic, strong) UILabel *photosBytesLabel;

@property (nonatomic, strong) UIButton *doneButton;

@property (nonatomic, assign) BOOL allowSelectOriginal;

@property (nonatomic, assign) BOOL allowEdit;

@property (nonatomic, copy) WBEditActionCompletion editActionCompletion;
@property (nonatomic, copy) WBPreviewActionCompletion previewActionCompletion;
@property (nonatomic, copy) WBOriginalPhotoActionCompletion originalPhotoActionCompletion;
@property (nonatomic, copy) WBDoneActionCompletion doneActionCompletion;

+ (instancetype)bottomToolBarWithFrame:(CGRect)frame owner:(id)owner;
+ (instancetype)bottomToolBarWithFrame:(CGRect)frame owner:(id)owner source:(WBPhotoBrowserSource)source preView:(BOOL)isPreView;

- (instancetype _Nullable)init NS_UNAVAILABLE;
+ (instancetype _Nullable)new NS_UNAVAILABLE;

- (void)resetThumbnailBottomBtnsStatus:(BOOL)getBytes;

- (void)getOriginalImageBytes:(NSArray<ZLPhotoModel *> * _Nullable)photos;

#pragma mark -- big image
- (void)resetBigImageOriginalBtnState:(ZLPhotoModel *)m;

- (void)resetBigImageDontBtnState:(ZLPhotoModel *)m;

- (void)resetBigImageEditBtnState:(ZLPhotoModel *)m;

@end

NS_ASSUME_NONNULL_END
