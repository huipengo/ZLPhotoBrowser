//
//  ZLPhotoConfiguration.m
//  ZLPhotoBrowser
//
//  Created by long on 2017/11/16.
//  Copyright © 2017年 long. All rights reserved.
//

#import "ZLPhotoConfiguration.h"

@implementation ZLPhotoConfiguration

- (void)dealloc
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ZLCustomImageNames];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ZLLanguageTypeKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ZLCustomLanguageKeyValue];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    NSLog(@"---- %s", __FUNCTION__);
}

+ (nonnull instancetype)sharedConfiguration {
    static id _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [ZLPhotoConfiguration defaultPhotoConfiguration];
    });
    return _sharedInstance;
}

+ (instancetype)defaultPhotoConfiguration
{
    ZLPhotoConfiguration *configuration = [[ZLPhotoConfiguration alloc] init];
    
    configuration.statusBarStyle = UIStatusBarStyleLightContent;
    configuration.maxSelectCount = 9;
    configuration.mutuallyExclusiveSelectInMix = NO;
    configuration.maxPreviewCount = 20;
    configuration.cellCornerRadio = .0;
    configuration.allowSelectImage = YES;
    configuration.allowSelectVideo = YES;
    configuration.allowSelectGif = YES;
    configuration.allowSelectLivePhoto = NO;
    configuration.allowTakePhotoInLibrary = NO;
    configuration.allowForceTouch = YES;
    configuration.allowEditImage = YES;
    configuration.allowEditVideo = NO;
    configuration.allowSelectOriginal = YES;
    configuration.maxEditVideoTime = 10;
    configuration.maxVideoDuration = 300;
    configuration.allowSlideSelect = YES;
    configuration.allowDragSelect = NO;
//    configuration.editType = ZLImageEditTypeClip;
    configuration.clipRatios = @[GetCustomClipRatio(),
                                 GetClipRatio(1, 1),
                                 GetClipRatio(4, 3),
                                 GetClipRatio(3, 2),
                                 GetClipRatio(16, 9)];
    configuration.editAfterSelectThumbnailImage = NO;
    configuration.saveNewImageAfterEdit = YES;
    configuration.showCaptureImageOnTakePhotoBtn = YES;
    configuration.sortAscending = YES;
    configuration.showSelectBtn = NO;
    configuration.doneBtnTitle = GetLocalLanguageTextValue(ZLPhotoBrowserDoneText);
    configuration.navBarColor = kRGB(54, 52, 51);
    configuration.navTitleColor = [UIColor whiteColor];
    configuration.previewTextColor = [UIColor blackColor];
    configuration.bottomViewBgColor = kRGB(54, 52, 51);
    configuration.bottomBtnsNormalTitleColor = [UIColor whiteColor];
    configuration.bottomBtnsDisableTitleColor = kRGBA(255, 255, 255, 0.2);
    configuration.bottomBtnsNormalBgColor = kRGB(52, 120, 246);
    configuration.bottomBtnsDisableBgColor = kRGB(76, 76, 76);
    configuration.showSelectedMask = NO;
    configuration.selectedMaskColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    configuration.showInvalidMask = YES;
    configuration.invalidMaskColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    configuration.showSelectedIndex = YES;
    configuration.indexLabelBgColor = kRGB(52, 120, 246);
    configuration.cameraProgressColor = kRGB(80, 169, 52);
    configuration.customImageNames = nil;
    configuration.shouldAnialysisAsset = YES;
    configuration.timeout = 20;
    configuration.languageType = ZLLanguageSystem;
    configuration.useSystemCamera = NO;
    configuration.allowRecordVideo = YES;
    configuration.maxRecordDuration = 10;
    configuration.sessionPreset = ZLCaptureSessionPreset1280x720;
    configuration.exportVideoType = ZLExportVideoTypeMov;
    
    [configuration configDefaultImage];
    
    return configuration;
}

- (BOOL)showSelectBtn
{
    return _maxSelectCount > 1 ? YES : _showSelectBtn;
}

- (void)setAllowSelectLivePhoto:(BOOL)allowSelectLivePhoto
{
    if (@available(iOS 9.1, *)) {
        _allowSelectLivePhoto = allowSelectLivePhoto;
    } else {
        _allowSelectLivePhoto = NO;
    }
}

- (void)setMaxEditVideoTime:(NSInteger)maxEditVideoTime
{
    _maxEditVideoTime = MAX(maxEditVideoTime, 5);
}

- (void)setCustomImageNames:(NSArray<NSString *> *)customImageNames
{
    [[NSUserDefaults standardUserDefaults] setValue:customImageNames forKey:ZLCustomImageNames];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setLanguageType:(ZLLanguageType)languageType
{
    [[NSUserDefaults standardUserDefaults] setValue:@(languageType) forKey:ZLLanguageTypeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [NSBundle resetLanguage];
}

- (void)setCustomLanguageKeyValue:(NSDictionary<NSString *,NSString *> *)customLanguageKeyValue
{
    [[NSUserDefaults standardUserDefaults] setValue:customLanguageKeyValue forKey:ZLCustomLanguageKeyValue];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setMaxRecordDuration:(NSInteger)maxRecordDuration
{
    _maxRecordDuration = MAX(maxRecordDuration, 1);
}

//- (void)setEditType:(ZLImageEditType)editType
//{
//    assert(editType != 0);
//
//    if (editType == 0) {
//        _editType = ZLImageEditTypeClip;
//    } else {
//        _editType = editType;
//    }
//}

- (void)configDefaultImage {
    self.btn_original_circle_image   = GetImageWithName(@"zl_btn_original_circle");
    self.btn_original_selected_image = GetImageWithName(@"zl_btn_original_selected");
    self.btn_original_circle_disabled_image = GetImageWithName(@"zl_btn_original_circle_disabled");
    self.placeholder_photo_image = GetImageWithName(@"zl_defaultphoto");
    self.play_video_image = GetImageWithName(@"zl_playVideo");
    self.video_load_failed_image = GetImageWithName(@"zl_videoLoadFailed");
    self.video_view_image = GetImageWithName(@"zl_videoView");
    self.btn_unselected_image = GetImageWithName(@"zl_btn_unselected");
    self.btn_selected_image = GetImageWithName(@"zl_btn_selected");
    self.video_image = GetImageWithName(@"zl_video");
    self.live_photo_image = GetImageWithName(@"zl_livePhoto");
    self.take_photo_image = GetImageWithName(@"zl_takePhoto");
    self.arrow_down_image = GetImageWithName(@"zl_arrow_down");
    self.retake_image = GetImageWithName(@"zl_retake");
    self.takeok_image = GetImageWithName(@"zl_takeok");
    self.focus_image = GetImageWithName(@"zl_focus");
    self.toggle_camera_image = GetImageWithName(@"zl_toggle_camera");
    self.ic_left_image = GetImageWithName(@"zl_ic_left");
    self.ic_right_image = GetImageWithName(@"zl_ic_right");
    self.nav_back_image = GetImageWithName(@"zl_navBack");
    self.lock_image = GetImageWithName(@"zl_lock");
    self.play_button_white_image = GetImageWithName(@"zl_playButtonWhite");
    self.pause_button_white_image = GetImageWithName(@"zl_pauseButtonWhite");
    self.icon_selected_image = GetImageWithName(@"icon_selected");
    self.drop_menu_down_image = GetImageWithName(@"drop_menu_down");
    self.clip_image = GetImageWithName(@"zl_clip");
    self.rotate_image = GetImageWithName(@"zl_rotateimage");
    self.draw_image = GetImageWithName(@"zl_draw");
    self.revoke_image = GetImageWithName(@"zl_revoke");
    self.btn_rotate_image = GetImageWithName(@"zl_btn_rotate");
}

@end
