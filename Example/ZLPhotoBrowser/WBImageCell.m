//
//  WBImageCell.m
//  ZLPhotoBrowser_Example
//
//  Created by huipeng on 2020/8/10.
//  Copyright © 2020 huipeng. All rights reserved.
//

#import "WBImageCell.h"

@implementation WBImageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.frame = self.contentView.bounds;
        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:self.imageView];
        
        self.playImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2-15, self.bounds.size.height/2-15, 30, 30)];
        self.playImageView.image = [UIImage imageNamed:@"playVideo"];
        [self.contentView addSubview:self.playImageView];
    }
    return self;
}

@end
