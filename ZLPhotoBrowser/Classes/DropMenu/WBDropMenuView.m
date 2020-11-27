//
//  WBDropMenuView.m
//  WIMDropDownMenu
//
//  Created by huipeng on 2020/8/6.
//  Copyright © 2020 huipeng. All rights reserved.
//

#import "WBDropMenuView.h"
#import "WBDropMenuCell.h"
#import "WBDropMenuUtil.h"
#import "ZLDefine.h"
#import "ZLPhotoConfiguration.h"

static CGFloat const wb_menu_button_height = 33.0f;
static CGFloat const wb_menu_cell_height   = 55.0f;

@interface WBDropMenuView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIButton *menuButton;

@property (nonatomic, assign, getter=isShow) BOOL show;
@property (nonatomic, strong) NSMutableArray *menuArray;

@property (nonatomic, weak)   UIView *contentView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong, readwrite) UIView *maskView;

@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation WBDropMenuView

+ (instancetype)menuViewWithFrame:(CGRect)frame inSuperView:(UIView *)superView {
    WBDropMenuView *menuView = [[WBDropMenuView alloc] initWithFrame:frame];
    menuView.contentView = superView;
    return menuView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.menuCellHeight  = wb_menu_cell_height;
    [self addSubview:self.menuButton];
}

- (void)reloadData {
    [self reloadMenuTitle];
    [self.tableView reloadData];
}

#pragma mark - menu action
- (void)_dropMenuAction:(UIButton *)sender {
    if (!self.isShow) {
        [self _showMenuView];
    }
    else {
        [self _hiddenMenuView];
    }
}

- (void)_showMenuView {
    [self _setupContentView];
    [UIView animateWithDuration:0.25f animations:^{
        self.menuButton.imageView.transform = CGAffineTransformMakeRotation(M_PI);
        
        CGRect frame     = self.tableView.frame;
        CGFloat top_h    = [WBDropMenuUtil wb_status_navBarHeight];
        CGFloat bottom_h = [WBDropMenuUtil wb_safeBottomMargin];
        CGFloat screen_h = [UIScreen mainScreen].bounds.size.height - top_h - bottom_h - 44.0f;
        
        NSInteger menu_count = [self _numberOfRows];
        CGFloat table_h = MIN(self.menuCellHeight * menu_count, screen_h);
        frame.size.height = table_h;
        self.tableView.frame = frame;
                
        self.maskView.hidden = NO;
        self.maskView.alpha  = 1.0;
    } completion:^(BOOL finished) {
        self.show = !self.isShow;
    }];
}

- (void)_hiddenMenuView {
    [UIView animateWithDuration:0.25f animations:^{
        self.menuButton.imageView.transform = CGAffineTransformMakeRotation(0);
        
        CGRect frame = self.tableView.frame;
        frame.size.height    = 0.0f;
        self.tableView.frame = frame;
        
        self.maskView.hidden = YES;
        self.maskView.alpha  = 0.0;
    } completion:^(BOOL finished) {
        self.show = !self.isShow;
    }];
}

- (void)_setupContentView {
    if (![self.maskView isDescendantOfView:self.superview]) {
        [self.contentView addSubview:self.maskView];
    }
    
    if (![self.tableView isDescendantOfView:self.superview]) {
        [self.contentView addSubview:self.tableView];
    }
}

#pragma mark -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.menuCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self _numberOfRows];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WBDropMenuCell *cell = [WBDropMenuCell wb_cellForTableView:tableView];
    
    ZLAlbumListModel *item = [self _selectMenuRowAtIndex:indexPath.row];
    item.selected = (self.selectedIndex == indexPath.row);
    cell.item = item;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _selectedIndex = indexPath.row;
    [self reloadData];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(menuView:didSelectRowAtIndexPath:)]) {
        [self.delegate menuView:self didSelectRowAtIndexPath:indexPath];
        [self _hiddenMenuView];
    }
}

#pragma mark --
- (NSInteger)_numberOfRows {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(menuNumberOfRows)]) {
        return [self.dataSource menuNumberOfRows];
    }
    return 0;
}

- (ZLAlbumListModel *)_selectMenuRowAtIndex:(NSInteger)index {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(menuItemForRow:)]) {
        ZLAlbumListModel *item = [self.dataSource menuItemForRow:index];
        return item;
    }
    return nil;
}

- (UIEdgeInsets)_menuViewContentInset {
    if (self.delegate && [self.delegate respondsToSelector:@selector(menuViewContentInset)]) {
        return [self.delegate menuViewContentInset];
    }
    else {
        UIEdgeInsets inset = UIEdgeInsetsZero;
        if (@available(iOS 11, *)) {
            inset = self.contentView.safeAreaInsets;
        }
        return inset;
    }
}

#pragma mark --
- (void)reloadMenuTitle {
    ZLAlbumListModel *item = [self _selectMenuRowAtIndex:_selectedIndex];
    NSString *title = item.title;
    [self.menuButton setTitle:title forState: UIControlStateNormal];
    [self.menuButton.titleLabel sizeToFit];
    
    CGFloat menu_h = wb_menu_button_height;
    CGFloat menu_w = self.menuButton.titleLabel.frame.size.width + 20.0 + 30.0;
    CGFloat menu_x = (self.frame.size.width  - menu_w) / 2.0f;
    CGFloat menu_y = (self.frame.size.height - menu_h) / 2.0f;
    _menuButton.frame = CGRectMake(menu_x, menu_y, menu_w, menu_h);
    
    _menuButton.layer.cornerRadius  = menu_h / 2.0f;
    _menuButton.layer.masksToBounds = YES;
    
    ZLPhotoConfiguration *configuration = ZLPhotoConfiguration.sharedConfiguration;
    UIImage *image = configuration.drop_menu_down_image;
    [_menuButton setImage:image forState:UIControlStateNormal];
    CGFloat margin   = 4.0f;
    CGFloat trailing = 6.0f;
    CGFloat image_width = (_menuButton.imageView.image.size.width + margin);
    CGFloat title_width = (_menuButton.titleLabel.bounds.size.width + margin);
    UIEdgeInsets titleEdgeInsets = UIEdgeInsetsMake(0.0f, -image_width + trailing, 0.0f, image_width);
    [_menuButton setTitleEdgeInsets:titleEdgeInsets];
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsMake(0.0f, title_width, 0.0f, -title_width - trailing);
    [_menuButton setImageEdgeInsets:imageEdgeInsets];
}

#pragma mark -- getter
- (UIButton *)menuButton {
    if (!_menuButton) {
        _menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _menuButton.backgroundColor = [UIColor colorWithRed:76/255.0 green:76/255.0 blue:76/255.0 alpha:1.0];
        _menuButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [_menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_menuButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.68f] forState:UIControlStateHighlighted];
        [_menuButton addTarget:self action:@selector(_dropMenuAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _menuButton;
}

- (UITableView *)tableView {
    if (!_tableView) {
        UIEdgeInsets contentInset = [self _menuViewContentInset];
        CGRect frame  = CGRectMake(contentInset.left, contentInset.top,
                                   [UIScreen mainScreen].bounds.size.width, 0.0f);
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.backgroundColor = [WBDropMenuUtil wb_backgroundColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = [UIColor colorWithRed:63/255.0 green:63/255.0 blue:63/255.0 alpha:1.0];
        _tableView.separatorInset = UIEdgeInsetsMake(0.0f, 56.0f, 0.0f, 0.0f);
        if (@available(iOS 11.0, *)) {
            [_tableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAlways];
        }
    }
    return _tableView;
}

- (UIView *)maskView {
    if (!_maskView) {
        CGFloat mask_y = self.tableView.frame.origin.y;
        CGFloat mask_w = self.tableView.frame.size.width;
        CGFloat mask_h = [UIScreen mainScreen].bounds.size.height - mask_y;
        CGRect frame   = CGRectMake(self.tableView.frame.origin.x, mask_y, mask_w, mask_h);
        _maskView = [[UIView alloc] initWithFrame:frame];
        _maskView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        _maskView.hidden = YES;
        _maskView.alpha  = 0.0;
        
        UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_hiddenMenuView)];
        [_maskView addGestureRecognizer:gesture];
    }
    return _maskView;
}

@end
