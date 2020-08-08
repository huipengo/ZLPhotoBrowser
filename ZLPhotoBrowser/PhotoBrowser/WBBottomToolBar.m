//
//  WBBottomToolBar.m
//  ZLPhotoBrowserFramework
//
//  Created by huipeng on 2020/8/7.
//  Copyright © 2020 long. All rights reserved.
//

#import "WBBottomToolBar.h"
#import "ZLDefine.h"
#import "ZLPhotoConfiguration.h"
#import "ZLAlbumListController.h"
#import "ZLPhotoManager.h"

CGFloat const WBBottomToolBarHeight = 56.0f;

@interface WBBottomToolBar ()

@property (nonatomic, strong) UIVisualEffectView *effectView;

@property (nonatomic, strong) UIView *line;

@property (nonatomic, weak) ZLImageNavigationController *nav;

@property (nonatomic, strong) ZLPhotoConfiguration *configuration;

// 是否是预览已选择的照片/网络图片（预览本地/网络图片/视频时，不显示原图按钮）
@property (nonatomic, assign, getter=isPreView) BOOL preView;

// 来源
@property (nonatomic, assign) WBPhotoBrowserSource source;

@end

@implementation WBBottomToolBar

+ (instancetype)bottomToolBarWithFrame:(CGRect)frame owner:(UIViewController *)owner {
    return [self bottomToolBarWithFrame:frame owner:owner source:WBPhotoBrowserThumbnail preView:NO];
}

+ (instancetype)bottomToolBarWithFrame:(CGRect)frame owner:(UIViewController *)owner source:(WBPhotoBrowserSource)source preView:(BOOL)isPreView {
    WBBottomToolBar *bottomToolBar = [[WBBottomToolBar alloc] initWithFrame:frame];
    bottomToolBar.nav = (ZLImageNavigationController *)owner.navigationController;
    bottomToolBar.configuration = bottomToolBar.nav.configuration;
    bottomToolBar.source = source;
    bottomToolBar.preView = isPreView;
    [bottomToolBar _initSubviews];
    return bottomToolBar;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self _initSubviews];
}

- (void)_initSubviews {
    self.backgroundColor = self.configuration.bottomViewBgColor;
    self.alpha = 0.9f;
    [self addSubview:self.effectView];
    [self addSubview:self.line];
    
    self.allowEdit = self.configuration.allowEditImage || self.configuration.allowEditVideo;
    if (self.allowEdit) {
        [self addSubview:self.editButton];
    }
    
    if (self.source == WBPhotoBrowserThumbnail) {
        [self addSubview:self.previewButton];
    }
    
    self.allowSelectOriginal = self.configuration.allowSelectOriginal &&
                               self.configuration.allowSelectImage &&
                               (!self.isPreView); /** 预览本地/网络图片/视频时，不显示原图按钮 */
    
    if (self.allowSelectOriginal) {
        [self addSubview:self.originalPhotoButton];
        [self addSubview:self.photosBytesLabel];
    }
    
    [self addSubview:self.doneButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.line.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 1.0f / [UIScreen mainScreen].scale);
    self.effectView.frame = self.bounds;
    
    CGFloat offsetX = 15.0f;
    CGFloat offsetY = 10.0f;
    CGFloat bottomBtnH = 33.0f;
    if (self.allowEdit) {
        self.editButton.frame = CGRectMake(offsetX, offsetY, GetMatchValue(GetLocalLanguageTextValue(ZLPhotoBrowserEditText), 15.0f, YES, bottomBtnH), bottomBtnH);
        offsetX = CGRectGetMaxX(self.editButton.frame) + 15.0f;
    }
    
    self.previewButton.frame = CGRectMake(offsetX, offsetY, GetMatchValue(GetLocalLanguageTextValue(ZLPhotoBrowserPreviewText), 15.0f, YES, bottomBtnH), bottomBtnH);
    offsetX = CGRectGetMaxX(self.previewButton.frame) + 10.0f;
    
    if (self.allowSelectOriginal) {
        CGFloat photosBytes_w = 80.0f;
        offsetX = (self.frame.size.width - self.originalPhotoButton.frame.size.width) / 2.0f;
        self.originalPhotoButton.frame = CGRectMake(offsetX, offsetY, GetMatchValue(GetLocalLanguageTextValue(ZLPhotoBrowserOriginalText), 15.0f, YES, bottomBtnH) + 30.0f, bottomBtnH);
        
        offsetX = CGRectGetMaxX(self.originalPhotoButton.frame);
        self.photosBytesLabel.frame = CGRectMake(offsetX, offsetY, photosBytes_w, bottomBtnH);
    }
    
    CGFloat doneWidth = GetMatchValue(self.doneButton.currentTitle, 15.0f, YES, bottomBtnH);
    doneWidth = MAX(70.0f, doneWidth);
    self.doneButton.frame = CGRectMake(self.frame.size.width - doneWidth - 12.0f, offsetY, doneWidth, bottomBtnH);
    self.doneButton.layer.cornerRadius  = bottomBtnH / 2.0f;
    self.doneButton.layer.masksToBounds = YES;
}

- (void)resetThumbnailBottomBtnsStatus:(BOOL)getBytes
{
    ZLPhotoConfiguration *configuration = self.configuration;
    
    if (self.nav.arrSelectedModels.count > 0) {
        self.originalPhotoButton.enabled = YES;
        self.previewButton.enabled = YES;
        self.doneButton.enabled = YES;
        if (self.nav.isSelectOriginalPhoto) {
            if (getBytes) [self getOriginalImageBytes:nil];
        } else {
            self.photosBytesLabel.text = nil;
        }
        self.originalPhotoButton.selected = self.nav.isSelectOriginalPhoto;
        NSString *doneTitle = [NSString stringWithFormat:@"%@(%ld)", GetLocalLanguageTextValue(ZLPhotoBrowserDoneText), self.nav.arrSelectedModels.count];
        [self.doneButton setTitle:doneTitle forState:UIControlStateNormal];
        self.doneButton.backgroundColor = configuration.bottomBtnsNormalBgColor;
    }
    else {
        self.originalPhotoButton.selected = NO;
        self.originalPhotoButton.enabled = NO;
        self.previewButton.enabled = NO;
        self.doneButton.enabled = NO;
        self.photosBytesLabel.text = nil;
        [self.doneButton setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserDoneText) forState:UIControlStateDisabled];
        self.doneButton.backgroundColor = configuration.bottomBtnsDisableBgColor;
    }
    
    BOOL canEdit = NO;
    if (self.nav.arrSelectedModels.count == 1) {
        ZLPhotoModel *m = self.nav.arrSelectedModels.firstObject;
        canEdit = (configuration.allowEditImage && ((m.type == ZLAssetMediaTypeImage) ||
        (m.type == ZLAssetMediaTypeGif && !configuration.allowSelectGif) ||
        (m.type == ZLAssetMediaTypeLivePhoto && !configuration.allowSelectLivePhoto))) ||
        (configuration.allowEditVideo && m.type == ZLAssetMediaTypeVideo && round(m.asset.duration) >= configuration.maxEditVideoTime);
    }
    [self.editButton setTitleColor:canEdit?configuration.bottomBtnsNormalTitleColor:configuration.bottomBtnsDisableTitleColor forState:UIControlStateNormal];
    self.editButton.userInteractionEnabled = canEdit;
}

#pragma mark -- show big image vc
- (void)resetBigImageOriginalBtnState:(ZLPhotoModel *)m
{
    ZLPhotoConfiguration *configuration = self.configuration;
    if ((m.type == ZLAssetMediaTypeImage) ||
         (m.type == ZLAssetMediaTypeGif && !configuration.allowSelectGif) ||
         (m.type == ZLAssetMediaTypeLivePhoto && !configuration.allowSelectLivePhoto)) {
        self.originalPhotoButton.hidden = NO;
        self.photosBytesLabel.hidden = NO;
    } else {
        self.originalPhotoButton.hidden = YES;
        self.photosBytesLabel.hidden = YES;
    }
}

- (void)resetBigImageDontBtnState:(ZLPhotoModel *)m
{
    ZLPhotoConfiguration *configuration = self.configuration;
    
    self.doneButton.hidden = NO;
    if (self.nav.arrSelectedModels.count > 0) {
        if (configuration.mutuallyExclusiveSelectInMix && configuration.maxSelectCount > 1) {
            ZLPhotoModel *model = m;
            _doneButton.hidden = model.type == ZLAssetMediaTypeVideo;
        }
        [_doneButton setTitle:[NSString stringWithFormat:@"%@(%ld)", GetLocalLanguageTextValue(ZLPhotoBrowserDoneText), self.nav.arrSelectedModels.count] forState:UIControlStateNormal];
    } else {
        [_doneButton setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserDoneText) forState:UIControlStateNormal];
    }
}

- (void)resetBigImageEditBtnState:(ZLPhotoModel *)m
{
    if (!self.allowEdit) return;
    
    BOOL flag = [m.asset.localIdentifier isEqualToString:self.nav.arrSelectedModels.firstObject.asset.localIdentifier];
    if ((self.nav.arrSelectedModels.count == 0 ||
         (self.nav.arrSelectedModels.count <= 1 && flag)) &&
        
        ((self.configuration.allowEditImage &&
         (m.type == ZLAssetMediaTypeImage ||
          (m.type == ZLAssetMediaTypeGif && !self.configuration.allowSelectGif) ||
          (m.type == ZLAssetMediaTypeLivePhoto && !self.configuration.allowSelectLivePhoto))) ||

         (self.configuration.allowEditVideo &&
          m.type == ZLAssetMediaTypeVideo &&
          round(m.asset.duration) >= self.configuration.maxEditVideoTime))) {
        
        _editButton.hidden = NO;
        
    } else {
        _editButton.hidden = YES;
    }
}

#pragma mark -- action
- (void)_editAction:(id)sender {
    !_editActionCompletion ?: _editActionCompletion(sender);
}

- (void)_previewAction:(id)sender {
    !_previewActionCompletion ?: _previewActionCompletion(sender);
}

- (void)_originalPhotoAction:(id)sender {
    [self _originalPhotoAction];
    !_originalPhotoActionCompletion ?: _originalPhotoActionCompletion(sender);
}

- (void)_doneAction:(id)sender {
    !_doneActionCompletion ?: _doneActionCompletion(sender);
}

- (void)_originalPhotoAction {
    self.originalPhotoButton.selected = !self.originalPhotoButton.selected;
    self.nav.isSelectOriginalPhoto    = self.originalPhotoButton.selected;
    self.photosBytesLabel.hidden      = !self.nav.isSelectOriginalPhoto;
    self.photosBytesLabel.text        = nil;
    
    if (self.source == WBPhotoBrowserThumbnail) {
        [self getOriginalImageBytes:nil];
    }
}

- (void)getOriginalImageBytes:(NSArray<ZLPhotoModel *> * _Nullable)photos {
    if (!self.nav.isSelectOriginalPhoto) { return; }
    if (photos == nil) { photos = self.nav.arrSelectedModels; }
    
    @zl_weakify(self);
    [ZLPhotoManager getPhotosBytesWithArray:self.nav.arrSelectedModels completion:^(NSString *photosBytes) {
        @zl_strongify(self);
        self.photosBytesLabel.text = [NSString stringWithFormat:@"(%@)", photosBytes];
    }];
}

#pragma mark -- getter
- (UIVisualEffectView *)effectView {
    if (!_effectView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    }
    return _effectView;
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = self.backgroundColor;
    }
    return _line;
}

- (UIButton *)editButton {
    if (!_editButton) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _editButton.titleLabel.font = [self wb_regularFontOfSize:15.0f];
        [_editButton setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserEditText) forState:UIControlStateNormal];
        [_editButton addTarget:self action:@selector(_editAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editButton;
}

- (UIButton *)previewButton {
    if (!_previewButton) {
        _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _previewButton.titleLabel.font = [self wb_regularFontOfSize:15.0f];
        [_previewButton setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserPreviewText) forState:UIControlStateNormal];
        [_previewButton setTitleColor:self.configuration.bottomBtnsNormalTitleColor forState:UIControlStateNormal];
        [_previewButton setTitleColor:self.configuration.bottomBtnsDisableTitleColor forState:UIControlStateDisabled];
        [_previewButton addTarget:self action:@selector(_previewAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _previewButton;
}

- (UIButton *)originalPhotoButton {
    if (!_originalPhotoButton) {
        _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalPhotoButton.titleLabel.font = [self wb_regularFontOfSize:15.0f];
        [_originalPhotoButton setImage:GetImageWithName(@"zl_btn_original_circle") forState:UIControlStateNormal];
        [_originalPhotoButton setImage:GetImageWithName(@"zl_btn_original_selected") forState:UIControlStateSelected];
        [_originalPhotoButton setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserOriginalText) forState:UIControlStateNormal];
        [_originalPhotoButton setTitleColor:self.configuration.bottomBtnsNormalTitleColor forState:UIControlStateNormal];
        [_originalPhotoButton setTitleColor:self.configuration.bottomBtnsDisableTitleColor forState:UIControlStateDisabled];
        [_originalPhotoButton addTarget:self action:@selector(_originalPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
        [_originalPhotoButton setImageEdgeInsets:UIEdgeInsetsMake(0.0f, -5.0f, 0.0f, 5.0f)];
    }
    return _originalPhotoButton;
}

- (UILabel *)photosBytesLabel {
    if (!_photosBytesLabel) {
        _photosBytesLabel = [[UILabel alloc] init];
        _photosBytesLabel.font = [self wb_regularFontOfSize:15.0f];
        _photosBytesLabel.textColor = self.configuration.bottomBtnsNormalTitleColor;
    }
    return _photosBytesLabel;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneButton.titleLabel.font = [self wb_mediumFontOfSize:15.0f];
        _doneButton.backgroundColor = self.configuration.bottomBtnsNormalBgColor;
        [_doneButton setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserDoneText) forState:UIControlStateNormal];
        [_doneButton setTitleColor:self.configuration.bottomBtnsNormalTitleColor forState:UIControlStateNormal];
        [_doneButton setTitleColor:self.configuration.bottomBtnsDisableTitleColor forState:UIControlStateDisabled];
        [_doneButton addTarget:self action:@selector(_doneAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

- (UIFont *)wb_regularFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"PingFangSC-Regular" size:fontSize];
}

- (UIFont *)wb_mediumFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"PingFangSC-Medium" size:fontSize];
}

@end
