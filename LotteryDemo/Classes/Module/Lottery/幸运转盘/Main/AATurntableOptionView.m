//
//  AATurntableOptionView.m
//  VoiceChat
//
//  Created by feng on 2021/1/13.
//  Copyright © 2021 NoCardData. All rights reserved.
//

#import "AATurntableOptionView.h"

@interface AATurntableOptionView ()

@property (weak, nonatomic) IBOutlet UIView *contentView1;
@property (weak, nonatomic) IBOutlet UIView *contentView2;
@property (weak, nonatomic) IBOutlet UIView *contentView3;

@property (weak, nonatomic) IBOutlet UIView *coverView1;
@property (weak, nonatomic) IBOutlet UIView *coverView2;
@property (weak, nonatomic) IBOutlet UIView *coverView3;

@property (weak, nonatomic) IBOutlet UILabel *countLabel1;
@property (weak, nonatomic) IBOutlet UILabel *countLabel2;
@property (weak, nonatomic) IBOutlet UILabel *countLabel3;

@property (weak, nonatomic) IBOutlet UILabel *costLabel1;
@property (weak, nonatomic) IBOutlet UILabel *costLabel2;
@property (weak, nonatomic) IBOutlet UILabel *costLabel3;

@end

@implementation AATurntableOptionView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self switchOption:0];
    
    CGFloat itemWidth = (kScreenWidth - 7 * 2 - 10 * 4) / 3.0;
    CGFloat itemHeight = 54.0 / 414.0 * kScreenWidth;
    
    self.contentView1.layer.cornerRadius = 10;
    self.contentView2.layer.cornerRadius = 10;
    self.contentView3.layer.cornerRadius = 10;

    self.contentView1.layer.borderColor = UIColorHex(#3B6CF1).CGColor;
    self.contentView2.layer.borderColor = UIColorHex(#3B6CF1).CGColor;
    self.contentView3.layer.borderColor = UIColorHex(#3B6CF1).CGColor;
    
    [self setupCoverView:self.coverView1
                 rect:CGRectMake(0, 0, itemWidth, itemHeight)
               colors:@[(__bridge id)UIColorHex(#7FB5FE).CGColor, (__bridge id)UIColorHex(#0D5DE8).CGColor]];
    [self setupCoverView:self.coverView2
                 rect:CGRectMake(0, 0, itemWidth, itemHeight)
               colors:@[(__bridge id)UIColorHex(#7FB5FE).CGColor, (__bridge id)UIColorHex(#0D5DE8).CGColor]];
    [self setupCoverView:self.coverView3
                 rect:CGRectMake(0, 0, itemWidth, itemHeight)
               colors:@[(__bridge id)UIColorHex(#7FB5FE).CGColor, (__bridge id)UIColorHex(#0D5DE8).CGColor]];
}

- (void)setupCoverView:(UIView *)view rect:(CGRect)rect colors:(NSArray *)colors
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = rect;
    gradient.startPoint = CGPointMake(0.5, 0);
    gradient.endPoint = CGPointMake(0.5, 1);
    gradient.locations = @[@(0), @(1.0f)];
    gradient.colors = colors;
    [view.layer insertSublayer:gradient atIndex:0];
}

- (IBAction)onClickBtn1:(id)sender
{
    [self switchOption:0];
}

- (IBAction)onClickBtn2:(id)sender
{
    [self switchOption:1];
}

- (IBAction)onClickBtn3:(id)sender
{
    [self switchOption:2];
}

/// 切换选项
- (void)switchOption:(NSInteger)index
{
    self.selectedIndex = index;
    switch (index) {
        case 0:
        {
            self.contentView1.layer.borderWidth = 0;
            self.contentView2.layer.borderWidth = 1;
            self.contentView3.layer.borderWidth = 1;
            
            self.coverView1.hidden = NO;
            self.coverView2.hidden = YES;
            self.coverView3.hidden = YES;
            
            self.countLabel1.textColor = UIColorHex(#FFFFFF);
            self.countLabel2.textColor = UIColorHex(#4F8CE8);
            self.countLabel3.textColor = UIColorHex(#4F8CE8);
            
            self.costLabel1.textColor = UIColorHex(#FFFFFF);
            self.costLabel2.textColor = UIColorHex(#4F8CE8);
            self.costLabel3.textColor = UIColorHex(#4F8CE8);
        }
            break;
        case 1:
        {
            self.contentView1.layer.borderWidth = 1;
            self.contentView2.layer.borderWidth = 0;
            self.contentView3.layer.borderWidth = 1;
            
            self.coverView1.hidden = YES;
            self.coverView2.hidden = NO;
            self.coverView3.hidden = YES;
            
            self.countLabel1.textColor = UIColorHex(#4F8CE8);
            self.countLabel2.textColor = UIColorHex(#FFFFFF);
            self.countLabel3.textColor = UIColorHex(#4F8CE8);
            
            self.costLabel1.textColor = UIColorHex(#4F8CE8);
            self.costLabel2.textColor = UIColorHex(#FFFFFF);
            self.costLabel3.textColor = UIColorHex(#4F8CE8);
        }
            break;
        case 2:
        {
            self.contentView1.layer.borderWidth = 1;
            self.contentView2.layer.borderWidth = 1;
            self.contentView3.layer.borderWidth = 0;
            
            self.coverView1.hidden = YES;
            self.coverView2.hidden = YES;
            self.coverView3.hidden = NO;
            
            self.countLabel1.textColor = UIColorHex(#4F8CE8);
            self.countLabel2.textColor = UIColorHex(#4F8CE8);
            self.countLabel3.textColor = UIColorHex(#FFFFFF);
            
            self.costLabel1.textColor = UIColorHex(#4F8CE8);
            self.costLabel2.textColor = UIColorHex(#4F8CE8);
            self.costLabel3.textColor = UIColorHex(#FFFFFF);
        }
            break;
        default:
            break;
    }
}

@end
