//
//  ZLImageNavigationController.m
//  ZLPhotoBrowserFramework
//
//  Created by huipeng on 2020/8/9.
//  Copyright © 2020 long. All rights reserved.
//

#import "ZLImageNavigationController.h"

@interface ZLImageNavigationController ()

@end

@implementation ZLImageNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.navigationBar.barStyle = UIBarStyleBlack;
        self.navigationBar.translucent = YES;
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (NSMutableArray<ZLPhotoModel *> *)arrSelectedModels
{
    if (!_arrSelectedModels) {
        _arrSelectedModels = [NSMutableArray array];
    }
    return _arrSelectedModels;
}

- (void)setConfiguration:(ZLPhotoConfiguration *)configuration
{
    _configuration = configuration;
    
    [UIApplication sharedApplication].statusBarStyle = self.configuration.statusBarStyle;
    [self.navigationBar setBackgroundImage:[self imageWithColor:configuration.navBarColor] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setTintColor:configuration.navTitleColor];
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: configuration.navTitleColor}];
//    UIImage *image = [GetImageWithName(@"zl_navBack") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    [self.navigationBar setBackIndicatorImage:image];
//    [self.navigationBar setBackIndicatorTransitionMaskImage:image];
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [UIApplication sharedApplication].statusBarStyle = self.configuration.statusBarStyle;
//}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = self.previousStatusBarStyle;
//    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.configuration.statusBarStyle;
}

@end
