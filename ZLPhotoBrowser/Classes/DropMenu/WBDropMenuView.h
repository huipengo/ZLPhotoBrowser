//
//  WBDropMenuView.h
//  WIMDropDownMenu
//
//  Created by huipeng on 2020/8/6.
//  Copyright © 2020 huipeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLPhotoModel.h"

NS_ASSUME_NONNULL_BEGIN

@class WBDropMenuView;
@protocol WBDropMenuDelegate <NSObject>

@required
- (void)menuView:(WBDropMenuView *)menuView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (UIEdgeInsets)menuViewContentInset;

@end

#pragma mark - 数据源
@protocol WBDropMenuDataSource <NSObject>

@required
- (ZLAlbumListModel *)menuItemForRow:(NSInteger)row;

- (NSInteger)menuNumberOfRows;

@end

@interface WBDropMenuView : UIView

@property (nonatomic, strong, readonly) UIView *maskView;

// default 55.0f
@property (nonatomic, assign) CGFloat menuCellHeight;

@property (nonatomic, weak) id<WBDropMenuDelegate> delegate;

@property (nonatomic, weak) id<WBDropMenuDataSource> dataSource;

+ (instancetype)menuViewWithFrame:(CGRect)frame inSuperView:(UIView *)superView;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
