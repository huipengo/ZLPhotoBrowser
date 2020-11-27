//
//  WBDropMenuCell.m
//  WIMDropDownMenu
//
//  Created by huipeng on 2020/8/6.
//  Copyright © 2020 huipeng. All rights reserved.
//

#import "WBDropMenuCell.h"
#import "WBDropMenuUtil.h"
#import "ZLDefine.h"
#import "ZLPhotoManager.h"
#import "ZLDefine.h"
#import "ZLPhotoConfiguration.h"

@interface WBDropMenuCell ()

@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UIImageView *arrowImgView;

@property (nonatomic, copy) NSString *identifier;

@end

@implementation WBDropMenuCell

+ (instancetype)wb_cellForTableView:(UITableView * _Nonnull)tableView {
    static NSString *cellIdentifier = @"wb_cellIdentifier";
    WBDropMenuCell *cell = [self.class wb_cellForTableView:tableView identifier:cellIdentifier];
    return cell;
}

+ (instancetype)wb_cellForTableView:(UITableView * _Nonnull)tableView identifier:(NSString * _Nonnull)identifier {
    WBDropMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[self.class alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0];
    cell.selectionStyle  = UITableViewCellSelectionStyleNone;

    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.arrowImgView];
    }
    return self;
}

- (void)setItem:(ZLAlbumListModel *)item {
    _item = item;
    
    @zl_weakify(self);
    
    self.identifier = item.headImageAsset.localIdentifier;
    ZLPhotoConfiguration *configuration = ZLPhotoConfiguration.sharedConfiguration;
    [ZLPhotoManager requestImageForAsset:item.headImageAsset size:CGSizeMake(GetViewHeight(self)*2.5, GetViewHeight(self)*2.5) progressHandler:nil completion:^(UIImage *image, NSDictionary *info) {
        @zl_strongify(self);
        
        if ([self.identifier isEqualToString:item.headImageAsset.localIdentifier]) {
            self.iconView.image = image?:configuration.placeholder_photo_image;
        }
    }];
    
    self.titleLabel.text = item.title;
    [self.titleLabel sizeToFit];
    
    self.contentLabel.text = [NSString stringWithFormat:@"（%ld）", (long)item.count];
    [self.contentLabel sizeToFit];
    
    self.arrowImgView.hidden = !item.isSelected;
}

- (void)layoutSubviews {
    CGRect t_frame = self.titleLabel.frame;
    t_frame.size.height = self.frame.size.height;
    self.titleLabel.frame = t_frame;
    
    CGFloat x = self.titleLabel.frame.origin.x + self.titleLabel.frame.size.width + 0.0f;
    self.contentLabel.frame = CGRectMake(x, 0.0, self.contentLabel.frame.size.width, self.frame.size.height);
    
    CGRect a_frame = self.arrowImgView.frame;
    a_frame.origin.x = self.frame.size.width - a_frame.size.width - 23.0f;
    a_frame.origin.y = (self.frame.size.height - a_frame.size.height) / 2.0f;
    self.arrowImgView.frame = a_frame;
}

#pragma mark --
- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 56.0f, 55.0f)];
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView.clipsToBounds = YES;
    }
    return _iconView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        CGFloat x = self.iconView.frame.origin.x + self.iconView.frame.size.width + 15.0f;
        CGRect frame = CGRectMake(x, 0.0f, 0.0f, self.frame.size.height);
        _titleLabel = [[UILabel alloc] initWithFrame:frame];
        _titleLabel.font = [UIFont systemFontOfSize:17.0f];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.font = [UIFont systemFontOfSize:15.0f];
        _contentLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
    }
    return _contentLabel;
}

- (UIImageView *)arrowImgView {
    if (!_arrowImgView) {
        ZLPhotoConfiguration *configuration = ZLPhotoConfiguration.sharedConfiguration;
        UIImage *image = configuration.icon_selected_image;
        _arrowImgView = [[UIImageView alloc] initWithImage:image];
        _arrowImgView.frame = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
        _arrowImgView.hidden = YES;
    }
    return _arrowImgView;
}

#pragma mark --
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self wb_setBackgroundColorDidSelected:selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self wb_setBackgroundColorDidSelected:highlighted];
}

- (void)wb_setBackgroundColorDidSelected:(BOOL)isSelected {
    UIColor *gBackGroundColor = isSelected ? [WBDropMenuUtil wb_highlightedColor] : [WBDropMenuUtil wb_backgroundColor];
    self.backgroundColor = gBackGroundColor;
}

@end
