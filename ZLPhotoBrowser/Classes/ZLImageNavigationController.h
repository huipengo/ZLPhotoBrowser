//
//  ZLImageNavigationController.h
//  ZLPhotoBrowserFramework
//
//  Created by huipeng on 2020/8/9.
//  Copyright © 2020 long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLPhotoConfiguration.h"
@class ZLPhotoModel;

NS_ASSUME_NONNULL_BEGIN

@interface ZLImageNavigationController : UINavigationController

@property (nonatomic, assign) UIStatusBarStyle previousStatusBarStyle;

/**
 是否选择了原图
 */
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;

@property (nonatomic, copy, nullable) NSMutableArray<ZLPhotoModel *> *arrSelectedModels;

/**
 相册框架配置
 */
@property (nonatomic, strong) ZLPhotoConfiguration *configuration;

/**
 点击确定选择照片回调
 */
@property (nonatomic, copy, nullable) void (^callSelectImageBlock)(void);

/**
 编辑图片后回调
 */
@property (nonatomic, copy, nullable) void (^callSelectClipImageBlock)(UIImage *, PHAsset *);

/**
 取消block
 */
@property (nonatomic, copy, nullable) void (^cancelBlock)(void);

@end

NS_ASSUME_NONNULL_END
