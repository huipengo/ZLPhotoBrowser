//
//  WBDropMenuCell.h
//  WIMDropDownMenu
//
//  Created by huipeng on 2020/8/6.
//  Copyright © 2020 huipeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLPhotoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WBDropMenuCell : UITableViewCell

@property (nonatomic, strong) ZLAlbumListModel *item;

+ (instancetype)wb_cellForTableView:(UITableView * _Nonnull)tableView;

@end

NS_ASSUME_NONNULL_END
