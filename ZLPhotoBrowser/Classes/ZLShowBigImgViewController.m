//
//  ZLShowBigImgViewController.m
//  多选相册照片
//
//  Created by long on 15/11/25.
//  Copyright © 2015年 long. All rights reserved.
//

#import "ZLShowBigImgViewController.h"
#import <Photos/Photos.h>
#import "ZLBigImageCell.h"
#import "ZLDefine.h"
#import "ToastUtils.h"
#import "ZLImageNavigationController.h"
#import "ZLPhotoModel.h"
#import "ZLPhotoManager.h"
#import "ZLEditViewController.h"
#import "ZLEditVideoController.h"
#import "ZLAnimateTransition.h"
#import "ZLInteractiveTrasition.h"
#import "ZLPullDownInteractiveTransition.h"
#import <SDWebImage/SDImageCodersManager.h>
#import <SDWebImage/SDImageGIFCoder.h>
#import "WBBottomToolBar.h"

@interface ZLShowBigImgViewController () <UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate>
{
    UICollectionView *_collectionView;
    
    UIButton *_btnBack;
    UIButton *_navRightBtn;
    UILabel *_indexLabel;
    UILabel *_titleLabel;
    
    // 底部view
    WBBottomToolBar *_bottomToolBar;

    NSArray *_arrSelPhotosBackup;
    NSMutableArray *_arrSelAssets;
    NSArray *_arrSelAssetsBackup;
    
    BOOL _isFirstAppear;
    
    BOOL _hideNavBar;
    
    // 设备旋转前的index
    NSInteger _indexBeforeRotation;
    UICollectionViewFlowLayout *_layout;
    
    NSString *_modelIdentifile;
    
    BOOL _shouldStartDismiss;
    NSInteger _panCount;
}

@property (nonatomic, assign) BOOL interactive;
@property (nonatomic, strong) ZLInteractiveTrasition *popTrasition;
@property (nonatomic, strong) ZLPullDownInteractiveTransition *dismissTrasition;

@end

@implementation ZLShowBigImgViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    NSLog(@"---- %s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;

    _isFirstAppear = YES;
    _currentPage   = self.selectIndex + 1;
    _indexBeforeRotation = self.selectIndex;
    
    [self initCollectionView];
    [self initNavView];
    [self initBottomView];
    [self resetDontBtnState];
    [self resetEditBtnState];
    [self resetNavBtnState];
    [self resetOriginalBtnState];
    
    if (!self.isPush) {
        self.dismissTrasition = [[ZLPullDownInteractiveTransition alloc] initWithViewController:self type:ZLDismissTypeDismiss];
        self.navigationController.transitioningDelegate = self;
    } else {
        self.navigationController.delegate = self;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [self.view addGestureRecognizer:pan];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    
    if (![[SDImageCodersManager sharedManager].coders containsObject:[SDImageGIFCoder sharedCoder]]) {
        [[SDImageCodersManager sharedManager] addCoder:[SDImageGIFCoder sharedCoder]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    if (!_isFirstAppear) {
        return;
    }
    [self resetIndexLabelState:NO];
    [_collectionView setContentOffset:CGPointMake((kViewWidth+kItemMargin)*_indexBeforeRotation, 0)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_isFirstAppear) {
        return;
    }
    _isFirstAppear = NO;
    [self reloadCurrentCell];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    UIEdgeInsets inset = UIEdgeInsetsMake(20, 0, 0, 0);
    if (@available(iOS 11, *)) {
        inset = self.view.safeAreaInsets;
    }
    _layout.minimumLineSpacing = kItemMargin;
    _layout.sectionInset = UIEdgeInsetsMake(0, kItemMargin/2, 0, kItemMargin/2);
    _layout.itemSize = CGSizeMake(kViewWidth, kViewHeight);
    [_collectionView setCollectionViewLayout:_layout];
    
    _collectionView.frame = CGRectMake(-kItemMargin/2, 0, kViewWidth + kItemMargin, kViewHeight);
    
    [_collectionView setContentOffset:CGPointMake((kViewWidth+kItemMargin) * _indexBeforeRotation, 0)];
    
    //nav view
    CGFloat navHeight = inset.top + 44.0f;
    CGRect navFrame = CGRectMake(0, 0, kViewWidth, navHeight);
    _navView.frame  = navFrame;
    
    _btnBack.frame     = CGRectMake(inset.left, inset.top, 60, 44.0f);
    _titleLabel.frame  = CGRectMake(kViewWidth / 2 - 50, inset.top, 100, 44.0f);
    _navRightBtn.frame = CGRectMake(kViewWidth - 40 - inset.right, inset.top + (44 - 25) / 2, 25, 25);
    _indexLabel.frame  = _navRightBtn.frame;
    
    //底部view
    CGFloat bottomViewH = WBBottomToolBarHeight;
    CGFloat toolBarH = (bottomViewH + inset.bottom);
    CGRect frame = CGRectMake(0, kViewHeight - toolBarH, kViewWidth, toolBarH);
    _bottomToolBar.frame = frame;
}

#pragma mark - 设备旋转
- (void)deviceOrientationChanged:(NSNotification *)notify
{
    _indexBeforeRotation = _currentPage - 1;
}

- (void)setModels:(NSArray<ZLPhotoModel *> *)models
{
    _models = models;
    // 如果预览数组中存在网络图片/视频则返回
    for (ZLPhotoModel *m in models) {
        if (m.type == ZLAssetMediaTypeNetImage ||
            m.type == ZLAssetMediaTypeNetVideo) {
            return;
        }
    }
    
    if (self.arrSelPhotos) {
        _arrSelAssets = [NSMutableArray array];
        for (ZLPhotoModel *m in models) {
            [_arrSelAssets addObject:m.asset];
        }
        _arrSelAssetsBackup = _arrSelAssets.copy;
    }
}

- (void)setArrSelPhotos:(NSMutableArray *)arrSelPhotos
{
    _arrSelPhotos = arrSelPhotos;
    _arrSelPhotosBackup = arrSelPhotos.copy;
}

- (ZLInteractiveTrasition *)popTrasition
{
    if (!_popTrasition) {
        _popTrasition = [[ZLInteractiveTrasition alloc] init];
        
        @zl_weakify(self);
        _popTrasition.beginTransitionBlock = ^{
            @zl_strongify(self);
            self->_navView.hidden = YES;
        };
        
        _popTrasition.cancelTransitionBlock = ^{
            @zl_strongify(self);
            self->_navView.hidden = self->_hideNavBar;
        };
    }
    return _popTrasition;
}

- (void)initNavView
{
    ZLPhotoConfiguration *configuration = [(ZLImageNavigationController *)self.navigationController configuration];
    
    _navView = [[UIView alloc] init];
    _navView.backgroundColor = [configuration.navBarColor colorWithAlphaComponent:.9];
    [self.view addSubview:_navView];
    
    _btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnBack setImage:GetImageWithName(@"zl_navBack") forState:UIControlStateNormal];
    [_btnBack setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [_btnBack addTarget:self action:@selector(btnBack_Click) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:_btnBack];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:18];
    _titleLabel.textColor = configuration.navTitleColor;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)_currentPage, (long)self.models.count];
    [_navView addSubview:_titleLabel];
    
    if (self.hideToolBar || (!configuration.showSelectBtn && !self.arrSelPhotos.count)) {
        return;
    }
    
    //right nav btn
    _navRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _navRightBtn.frame = CGRectMake(0, 0, 25, 25);
    UIImage *normalImg = GetImageWithName(@"zl_btn_unselected");
    UIImage *selImg = GetImageWithName(@"zl_btn_selected");
    [_navRightBtn setBackgroundImage:normalImg forState:UIControlStateNormal];
    [_navRightBtn setBackgroundImage:selImg forState:UIControlStateSelected];
    [_navRightBtn addTarget:self action:@selector(navRightBtn_Click:) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:_navRightBtn];
    
    // 图片选择index角标
    _indexLabel = [[UILabel alloc] init];
    _indexLabel.backgroundColor = configuration.indexLabelBgColor;
    _indexLabel.font = [UIFont systemFontOfSize:14];
    _indexLabel.textColor = [UIColor whiteColor];
    _indexLabel.textAlignment = NSTextAlignmentCenter;
    _indexLabel.layer.cornerRadius = 25.0 / 2;
    _indexLabel.layer.masksToBounds = YES;
    _indexLabel.hidden = YES;
    [_navView addSubview:_indexLabel];
    
    if (self.models.count == 1) {
        _navRightBtn.selected = self.models.firstObject.isSelected;
    }
    ZLPhotoModel *model = self.models[_currentPage-1];
    _navRightBtn.selected = model.isSelected;
}

#pragma mark - 初始化CollectionView
- (void)initCollectionView
{
    _layout = [[UICollectionViewFlowLayout alloc] init];
    _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
    [_collectionView registerClass:[ZLBigImageCell class] forCellWithReuseIdentifier:@"ZLBigImageCell"];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.scrollsToTop = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_collectionView];
}

- (void)initBottomView
{
    if (self.hideToolBar) return;
        
    _bottomToolBar = [WBBottomToolBar bottomToolBarWithFrame:CGRectZero
                                                       owner:self
                                                      source:WBPhotoBrowserBigImage
                                                     preView:self.isPreView];
    [self.view addSubview:_bottomToolBar];
    
    @zl_weakify(self);
    if (_bottomToolBar.allowSelectOriginal) {
        _bottomToolBar.originalPhotoActionCompletion = ^(id _Nonnull sender) {
            @zl_strongify(self);
            [self _originalImageAction:sender];
        };
    }
    
    if (_bottomToolBar.allowEdit) {
        _bottomToolBar.editActionCompletion = ^(id _Nonnull sender) {
            @zl_strongify(self);
            [self _editAction:sender];
        };
    }
    
    _bottomToolBar.doneActionCompletion = ^(id _Nonnull sender) {
        @zl_strongify(self);
        [self _doneAction:sender];
    };
    
    [self getPhotosBytes];
}

#pragma mark - UIButton Actions
- (void)_originalImageAction:(UIButton *)btn
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    ZLPhotoConfiguration *configuration = nav.configuration;
    
    if (btn.selected) {
        [self getPhotosBytes];
        if (!_navRightBtn.isSelected) {
            if (configuration.showSelectBtn &&
                nav.arrSelectedModels.count < configuration.maxSelectCount) {
                [self navRightBtn_Click:_navRightBtn];
            }
        }
    }
}

- (void)_editAction:(UIButton *)btn
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    ZLPhotoConfiguration *configuration = nav.configuration;
    
    BOOL flag = !_navRightBtn.isSelected && configuration.showSelectBtn &&
    nav.arrSelectedModels.count < configuration.maxSelectCount;
    
    ZLPhotoModel *model = self.models[_currentPage-1];
    if (flag) {
        [self navRightBtn_Click:_navRightBtn];
        if (![ZLPhotoManager judgeAssetisInLocalAblum:model.asset]) {
            return;
        }
    }
    
    if (model.type == ZLAssetMediaTypeVideo) {
        ZLEditVideoController *vc = [[ZLEditVideoController alloc] init];
        vc.model = model;
        [self.navigationController pushViewController:vc animated:NO];
    } else if (model.type == ZLAssetMediaTypeImage ||
               (model.type == ZLAssetMediaTypeGif && !configuration.allowSelectGif) ||
               (model.type == ZLAssetMediaTypeLivePhoto && !configuration.allowSelectLivePhoto)) {
        ZLEditViewController *vc = [[ZLEditViewController alloc] init];
        vc.model = model;
        ZLBigImageCell *cell = (ZLBigImageCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentPage-1 inSection:0]];
        vc.oriImage = cell.previewView.image;
        [self.navigationController pushViewController:vc animated:NO];
    }
}

- (void)_doneAction:(UIButton *)btn
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    ZLPhotoConfiguration *configuration = nav.configuration;
    
    if (!self.arrSelPhotos && nav.arrSelectedModels.count == 0) {
        ZLPhotoModel *model = self.models[_currentPage-1];
        if (![ZLPhotoManager judgeAssetisInLocalAblum:model.asset]) {
            ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowserLoadingText));
            return;
        }
        if (model.type == ZLAssetMediaTypeVideo && GetDuration(model.duration) > configuration.maxVideoDuration) {
            ShowToastLong(GetLocalLanguageTextValue(ZLPhotoBrowserMaxVideoDurationText), configuration.maxVideoDuration);
            return;
        }
        
        [nav.arrSelectedModels addObject:model];
    }
    if (self.arrSelPhotos && self.previewSelectedImageBlock) {
        self.previewSelectedImageBlock(self.arrSelPhotos, _arrSelAssets);
    }
    else if (self.arrSelPhotos && self.previewNetImageBlock) {
        self.previewNetImageBlock(self.arrSelPhotos);
    }
    else if (nav.callSelectImageBlock) {
        nav.callSelectImageBlock();
    }
}

- (void)btnBack_Click
{
    [self callBack];
    
    UIViewController *vc = [self.navigationController popViewControllerAnimated:YES];
    //由于collectionView的frame的width是大于该界面的width，所以设置这个颜色是为了pop时候隐藏collectionView的黑色背景
    _collectionView.backgroundColor = [UIColor clearColor];
    if (!vc) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)callBack
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    if (self.btnBackBlock) {
        self.btnBackBlock(nav.arrSelectedModels, nav.isSelectOriginalPhoto);
    }
    
    if (self.cancelPreviewBlock) {
        self.cancelPreviewBlock();
    }
}

- (void)navRightBtn_Click:(UIButton *)btn
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    ZLPhotoConfiguration *configuration = nav.configuration;
    
    ZLPhotoModel *model = self.models[_currentPage-1];
    if (configuration.mutuallyExclusiveSelectInMix && configuration.maxSelectCount > 1 && model.type == ZLAssetMediaTypeVideo) {
        return;
    }
    
    if (!btn.selected) {
        //选中
        [btn.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
        if (nav.arrSelectedModels.count >= configuration.maxSelectCount) {
            ShowToastLong(GetLocalLanguageTextValue(ZLPhotoBrowserMaxSelectCountText), configuration.maxSelectCount);
            return;
        }
        if (model.asset && ![ZLPhotoManager judgeAssetisInLocalAblum:model.asset]) {
            ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowserLoadingText));
            return;
        }
        if (model.type == ZLAssetMediaTypeVideo && GetDuration(model.duration) > configuration.maxVideoDuration) {
            ShowToastLong(GetLocalLanguageTextValue(ZLPhotoBrowserMaxVideoDurationText), configuration.maxVideoDuration);
            return;
        }
        
        model.selected = YES;
        [nav.arrSelectedModels addObject:model];
        [self resetIndexLabelState:YES];
        if (self.arrSelPhotos) {
            [self.arrSelPhotos addObject:_arrSelPhotosBackup[_currentPage-1]];
            [_arrSelAssets addObject:_arrSelAssetsBackup[_currentPage-1]];
        }
    } else {
        //移除
        model.selected = NO;
        for (ZLPhotoModel *m in nav.arrSelectedModels) {
            if ([m.asset.localIdentifier isEqualToString:model.asset.localIdentifier] ||
                [m.image isEqual:model.image] ||
                [m.url.absoluteString isEqualToString:model.url.absoluteString]) {
                [nav.arrSelectedModels removeObject:m];
                break;
            }
        }
        if (self.arrSelPhotos) {
            for (PHAsset *asset in _arrSelAssets) {
                if ([asset isEqual:_arrSelAssetsBackup[_currentPage-1]]) {
                    [_arrSelAssets removeObject:asset];
                    break;
                }
            }
            [self.arrSelPhotos removeObject:_arrSelPhotosBackup[_currentPage-1]];
        }
        
        [self resetIndexLabelState:NO];
    }
    
    btn.selected = !btn.selected;
    [self getPhotosBytes];
    [self resetDontBtnState];
    [self resetEditBtnState];
}

#pragma mark - panAction
- (void)panAction:(UIPanGestureRecognizer *)pan
{
    CGPoint p = [pan translationInView:self.view];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        _shouldStartDismiss = p.y >= 0;
        _panCount = 0;
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        if (!_shouldStartDismiss) return;
        
        _panCount++;
        
        if (_panCount == 1 && (p.y < 0 || atan(fabs(p.x)/fabs(p.y)) > M_PI_2/3)) {
            // 不满足下拉手势返回
            _shouldStartDismiss = NO;
        } else if (_panCount == 1) {
            _shouldStartDismiss = YES;
            self.interactive = YES;
            [self callBack];
            if (!self.popTrasition.isStartTransition) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        
        if (_shouldStartDismiss) {
            CGFloat percent = 0;
            percent = p.y / (self.view.superview.frame.size.height);
            percent = MAX(percent, 0);
            [self.popTrasition updatePercent:percent];
            [self.popTrasition updateInteractiveTransition:percent];
        }
    } else if (pan.state == UIGestureRecognizerStateCancelled ||
               pan.state == UIGestureRecognizerStateEnded) {
        if (_shouldStartDismiss && !self.popTrasition.isStartTransition) {
            // 快速拖动时候可能会走这里
            [self.popTrasition cancelInteractiveTransition];
            [self.popTrasition cancelAnimate];
            self.popTrasition = nil;
            self.interactive = NO;
            return;
        }
        
        if (_panCount == 0 || (!_shouldStartDismiss && !self.popTrasition.isStartTransition)) return;
        
        CGPoint vel = [pan velocityInView:self.view];
        
        CGFloat percent = 0;
        percent = p.y / (self.view.superview.frame.size.height);
        percent = MAX(percent, 0);
        
        BOOL dismiss = vel.y > 300 || (percent > 0.4 && vel.y > -300);
        
        if (dismiss) {
            [self.popTrasition finishInteractiveTransition];
            [self.popTrasition finishAnimate];
        } else {
            [self.popTrasition cancelInteractiveTransition];
            [self.popTrasition cancelAnimate];
        }
        self.popTrasition = nil;
        self.interactive = NO;
    }
}

- (void)showDownloadAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *save = [UIAlertAction actionWithTitle:GetLocalLanguageTextValue(ZLPhotoBrowserSaveText) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ZLProgressHUD *hud = [[ZLProgressHUD alloc] init];
        [hud show];
        
        ZLBigImageCell *cell = (ZLBigImageCell *)[self->_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self->_currentPage-1 inSection:0]];
        
        [ZLPhotoManager saveImageToAblum:cell.previewView.image completion:^(BOOL suc, PHAsset *asset) {
            [hud hide];
            if (!suc) {
                ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowserSaveImageErrorText));
            }
        }];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:GetLocalLanguageTextValue(ZLPhotoBrowserCancelText) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:save];
    [alert addAction:cancel];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)  {
        alert.popoverPresentationController.sourceView = self.view;
        alert.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(self.view.frame),
                                                                    CGRectGetMidY(self.view.frame),
                                                                    2, 2);
        alert.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }
    [self showDetailViewController:alert sender:nil];
}

#pragma mark - 更新按钮、导航条等显示状态

- (void)resetNavBtnState
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    ZLPhotoConfiguration *configuration = nav.configuration;
    if (configuration.mutuallyExclusiveSelectInMix && configuration.maxSelectCount > 1) {
        ZLPhotoModel *model = self.models[_currentPage-1];
        _navRightBtn.hidden = model.type == ZLAssetMediaTypeVideo;
    } else {
        _navRightBtn.hidden = !configuration.showSelectBtn;
    }
}

- (void)resetDontBtnState
{
    ZLPhotoModel *model = self.models[_currentPage - 1];
    [_bottomToolBar resetBigImageDontBtnState:model];
}

- (void)resetEditBtnState
{
    ZLPhotoModel *m = self.models[_currentPage-1];
    [_bottomToolBar resetBigImageEditBtnState:m];
}

- (void)resetIndexLabelState:(BOOL)animate
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    if (!nav.configuration.showSelectedIndex) {
        return;
    }
    
    ZLPhotoModel *m = [self getCurrentPageModel];
    if (!m) {
        return;
    }
    
    __block BOOL shouldShowIndex = NO;
    __block NSInteger index = 0;
    [nav.arrSelectedModels enumerateObjectsUsingBlock:^(ZLPhotoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.asset.localIdentifier isEqualToString:m.asset.localIdentifier] ||
            (obj.image != nil && [obj.image isEqual:m.image]) ||
            [obj.url.absoluteString isEqualToString:m.url.absoluteString]) {
            shouldShowIndex = YES;
            index = idx + 1;
            *stop = YES;
        }
    }];
    
    _indexLabel.hidden = !shouldShowIndex;
    _indexLabel.text = @(index).stringValue;
    
    if (animate) {
        [_indexLabel.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
    }
}

- (void)resetOriginalBtnState
{
    ZLPhotoModel *m = self.models[_currentPage-1];
    [_bottomToolBar resetBigImageOriginalBtnState:m];
}

- (void)getPhotosBytes
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    if (!nav.isSelectOriginalPhoto) return;
    
    ZLPhotoConfiguration *configuration = nav.configuration;
    
    NSArray *photos = configuration.showSelectBtn?nav.arrSelectedModels:@[self.models[_currentPage-1]];
    [_bottomToolBar getOriginalImageBytes:photos];
}

- (void)handlerSingleTap
{
    _hideNavBar = !_hideNavBar;
    
    _navView.hidden = _hideNavBar;
    _bottomToolBar.hidden = _hideNavBar;
}

#pragma mark - UICollectionDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.models.count;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [((ZLBigImageCell *)cell) resetCellStatus];
    ((ZLBigImageCell *)cell).willDisplaying = YES;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [((ZLBigImageCell *)cell) resetCellStatus];
    [((ZLBigImageCell *)cell).previewView handlerEndDisplaying];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLBigImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZLBigImageCell" forIndexPath:indexPath];
    ZLPhotoModel *model = self.models[indexPath.row];
    
    ZLPhotoConfiguration *configuration = [(ZLImageNavigationController *)self.navigationController configuration];
    
    cell.showGif = configuration.allowSelectGif;
    cell.showLivePhoto = configuration.allowSelectLivePhoto;
    cell.model = model;
    @zl_weakify(self);
    cell.singleTapCallBack = ^() {
        @zl_strongify(self);
        [self handlerSingleTap];
    };
    __weak typeof(cell) weakCell = cell;
    cell.longPressCallBack = ^{
        @zl_strongify(self);
        __strong typeof(weakCell) strongCell = weakCell;
        if (!strongCell.previewView.image) {
            return;
        }
        [self showDownloadAlert];
    };
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"controllerScrollViewDidScroll" object:nil];
    if (scrollView == (UIScrollView *)_collectionView) {
        ZLPhotoModel *m = [self getCurrentPageModel];
        if (!m) return;
        
        if ([_modelIdentifile isEqualToString:m.asset.localIdentifier]) return;
        
        _modelIdentifile = m.asset.localIdentifier;
        //改变导航标题
        _titleLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)_currentPage, (long)self.models.count];
        
        _navRightBtn.selected = m.isSelected;
        
        [self resetIndexLabelState:NO];
        [self resetOriginalBtnState];
        [self resetEditBtnState];
        [self resetNavBtnState];
        [self resetDontBtnState];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //单选模式下获取当前图片大小
    ZLPhotoConfiguration *configuration = [(ZLImageNavigationController *)self.navigationController configuration];
    if (!configuration.showSelectBtn) [self getPhotosBytes];
    
    [self reloadCurrentCell];
}

- (void)reloadCurrentCell
{
    ZLPhotoModel *m = [self getCurrentPageModel];
    if (m.type == ZLAssetMediaTypeGif ||
        m.type == ZLAssetMediaTypeNetImage ||
        m.type == ZLAssetMediaTypeLivePhoto ||
        m.type == ZLAssetMediaTypeVideo) {
        ZLBigImageCell *cell = (ZLBigImageCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentPage-1 inSection:0]];
        [cell reloadGifLivePhotoVideo];
    }
}

- (ZLPhotoModel *)getCurrentPageModel
{
    CGPoint offset = _collectionView.contentOffset;

    CGFloat page = offset.x/(kViewWidth+kItemMargin);
    if (ceilf(page) >= self.models.count ||
        page < 0) {
        return nil;
    }
    NSString *str = [NSString stringWithFormat:@"%.0f", page];
    _currentPage = str.integerValue + 1;
    ZLPhotoModel *model = self.models[_currentPage-1];
    return model;
}

#pragma mark - nav delegate
- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController
{
    return self.interactive ? self.popTrasition : nil;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC
{
    return self.interactive ? [ZLAnimateTransition new] : nil;
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return self.dismissTrasition.interactive ? self.dismissTrasition : nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self.dismissTrasition.interactive ? [ZLAnimateTransition new] : nil;
}

@end
