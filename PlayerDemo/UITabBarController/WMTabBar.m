//
//  WMTabBar.m
//  PlayerDemo
//
//  Created by apple on 2018/8/10.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import "WMTabBar.h"

@interface WMTabBar()
@property(nonatomic,assign)UIEdgeInsets oldSafeAreaInsets;
@end

@implementation WMTabBar
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.oldSafeAreaInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.oldSafeAreaInsets = UIEdgeInsetsZero;
}

- (void)safeAreaInsetsDidChange {
    [super safeAreaInsetsDidChange];
    if (!UIEdgeInsetsEqualToEdgeInsets(self.oldSafeAreaInsets, self.safeAreaInsets)) {
        [self invalidateIntrinsicContentSize];
        if (self.superview) {
            [self.superview setNeedsLayout];
            [self.superview layoutSubviews];
        }
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    size = [super sizeThatFits:size];
    if (@available(iOS 11.0, *)) {
        float bottomInset = self.safeAreaInsets.bottom;
        if (bottomInset > 0 && size.height < 50 && (size.height + bottomInset < 90)) {
            size.height += bottomInset;
        }
    }
    return size;
}


- (void)setFrame:(CGRect)frame {
    if (self.superview) {
        if (frame.origin.y + frame.size.height != self.superview.frame.size.height) {
            frame.origin.y = self.superview.frame.size.height - frame.size.height;
        }
    }
    [super setFrame:frame];
}
@end

