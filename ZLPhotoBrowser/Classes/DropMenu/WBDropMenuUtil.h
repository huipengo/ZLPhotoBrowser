//
//  WBDropMenuUtil.h
//  WIMDropDownMenu
//
//  Created by huipeng on 2020/8/6.
//  Copyright © 2020 huipeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WBDropMenuUtil : NSObject

+ (UIColor *)wb_backgroundColor;

+ (UIColor *)wb_highlightedColor;

+ (UIColor *)wb_dynamicProviderLightColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor;

+ (CGFloat)wb_statusBarHeight;

+ (CGFloat)wb_navBarHeight;

+ (CGFloat)wb_status_navBarHeight;

+ (CGFloat)wb_safeBottomMargin;

@end

NS_ASSUME_NONNULL_END
