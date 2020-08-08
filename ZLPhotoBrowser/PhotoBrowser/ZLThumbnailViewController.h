//
//  ZLThumbnailViewController.h
//  多选相册照片
//
//  Created by long on 15/11/30.
//  Copyright © 2015年 long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBBottomToolBar.h"

@class ZLAlbumListModel;

@interface ZLThumbnailViewController : UIViewController

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) WBBottomToolBar *bottomToolBar;

// 相册model
@property (nonatomic, strong) ZLAlbumListModel *albumListModel;

@end
