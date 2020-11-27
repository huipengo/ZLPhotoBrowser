//
//  ZLPhotoBrowserCell.m
//  多选相册照片
//
//  Created by long on 15/11/30.
//  Copyright © 2015年 long. All rights reserved.
//

#import "ZLPhotoBrowserCell.h"
#import "ZLPhotoModel.h"
#import "ZLPhotoManager.h"
#import "ZLDefine.h"
#import "ZLPhotoConfiguration.h"

@interface ZLPhotoBrowserCell ()

@property (nonatomic, copy) NSString *identifier;

@end

@implementation ZLPhotoBrowserCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setModel:(ZLAlbumListModel *)model {
    _model = model;
    
    if (self.cornerRadio > .0) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = self.cornerRadio;
    }
    
    @zl_weakify(self);
    
    self.identifier = model.headImageAsset.localIdentifier;
    ZLPhotoConfiguration *configuration = ZLPhotoConfiguration.sharedConfiguration;
    [ZLPhotoManager requestImageForAsset:model.headImageAsset size:CGSizeMake(GetViewHeight(self)*2.5, GetViewHeight(self)*2.5) progressHandler:nil completion:^(UIImage *image, NSDictionary *info) {
        @zl_strongify(self);
        
        if ([self.identifier isEqualToString:model.headImageAsset.localIdentifier]) {
            self.headImageView.image = image?:configuration.placeholder_photo_image;
        }
    }];
    
    self.labTitle.text = model.title;
    self.labCount.text = [NSString stringWithFormat:@"(%ld)", (long)model.count];
}

@end
