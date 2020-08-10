//
//  WBDropMenuUtil.m
//  WIMDropDownMenu
//
//  Created by huipeng on 2020/8/6.
//  Copyright © 2020 huipeng. All rights reserved.
//

#import "WBDropMenuUtil.h"

@implementation WBDropMenuUtil

+ (UIColor *)wb_backgroundColor {
    UIColor *lightColor = [UIColor colorWithRed:47.0/255.0 green:47.0/255.0 blue:46.0/255.0 alpha:1.0];
    UIColor *darkColor  = [UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0];
    UIColor *color = [self wb_dynamicProviderLightColor:lightColor darkColor:darkColor];
    return color;
}

+ (UIColor *)wb_highlightedColor {
    UIColor *lightColor = [UIColor colorWithRed:28.0f/255.0f green:28.0f/255.0f blue:30.0f/255.0f alpha:1.0f];
    UIColor *darkColor  = [UIColor colorWithRed:49.0f/255.0f green:49.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
    UIColor *color = [self wb_dynamicProviderLightColor:lightColor darkColor:darkColor];
    return color;
}

+ (UIColor *)wb_dynamicProviderLightColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor {
    if (@available(iOS 13.0, *)) {
        UIColor *color = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return darkColor;
            }
            return lightColor;
        }];
        return color;
    } else {
       return lightColor;
    }
}

+ (BOOL)wb_iPhoneXSeries NS_EXTENSION_UNAVAILABLE_IOS("") {
    static BOOL iPhoneXSeries = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
            iPhoneXSeries = NO;
        }
        
        if (@available(iOS 11.0, *)) {
            UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
            if (mainWindow.safeAreaInsets.bottom > 0.0) {
                iPhoneXSeries = YES;
            }
        }
    });
    
    return iPhoneXSeries;
}

+ (CGFloat)wb_statusBarHeight {
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}

+ (CGFloat)wb_navBarHeight {
    return 44.0f;
}

+ (CGFloat)wb_status_navBarHeight {
    return (self.wb_statusBarHeight + self.wb_navBarHeight);
}

+ (CGFloat)wb_safeBottomMargin {
    return (self.wb_iPhoneXSeries ? 34.0f : 0.0f);
}

@end
