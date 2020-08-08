//
//  ZLNoAuthorityViewController.m
//  多选相册照片
//
//  Created by long on 15/11/30.
//  Copyright © 2015年 long. All rights reserved.
//

#import "ZLNoAuthorityViewController.h"
#import "ZLDefine.h"
#import "ZLAlbumListController.h"

@interface ZLNoAuthorityViewController ()
{
    UIImageView *_imageView;
    UILabel *_labPrompt;
}

@end

@implementation ZLNoAuthorityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = GetLocalLanguageTextValue(ZLPhotoBrowserPhotoText);
    
    _imageView = [[UIImageView alloc] initWithImage:GetImageWithName(@"zl_lock")];
    _imageView.clipsToBounds = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.frame = CGRectMake((kViewWidth-kViewWidth/3)/2, 100, kViewWidth/3, kViewWidth/3);
    [self.view addSubview:_imageView];
    
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = GetMatchValue(GetLocalLanguageTextValue(ZLPhotoBrowserCancelText), 16, YES, 44);
    btn.frame = CGRectMake(0, 0, width+20, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserCancelText) forState:UIControlStateNormal];
    [btn setTitleColor:nav.configuration.navTitleColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(navRightBtn_Click) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    NSString *message = [NSString stringWithFormat:GetLocalLanguageTextValue(ZLPhotoBrowserNoAblumAuthorityText), kAPPName];
    
    _labPrompt = [[UILabel alloc] init];
    _labPrompt.numberOfLines = 0;
    _labPrompt.font = [UIFont systemFontOfSize:14];
    _labPrompt.textColor = kRGB(170, 170, 170);
    _labPrompt.text = message;
    _labPrompt.frame = CGRectMake(50, CGRectGetMaxY(_imageView.frame), kViewWidth-100, 100);
    _labPrompt.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_labPrompt];
    
    self.navigationItem.hidesBackButton = YES;
}

- (void)navRightBtn_Click
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
