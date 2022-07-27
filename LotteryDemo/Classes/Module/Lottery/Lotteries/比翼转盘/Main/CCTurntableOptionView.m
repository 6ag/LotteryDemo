//
//  CCTurntableOptionView.m
//  VoiceChat
//
//  Created by feng on 2021/1/13.
//  Copyright © 2021 NoCardData. All rights reserved.
//

#import "CCTurntableOptionView.h"

@interface CCTurntableOptionView ()

@property (weak, nonatomic) IBOutlet UILabel *costLabel1;
@property (weak, nonatomic) IBOutlet UILabel *costLabel2;
@property (weak, nonatomic) IBOutlet UILabel *costLabel3;

@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UIButton *btn3;

@end

@implementation CCTurntableOptionView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self switchText];
    [self switchOption:self.selectedIndex];
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
            self.btn1.selected = YES;
            self.btn2.selected = NO;
            self.btn3.selected = NO;
        }
            break;
        case 1:
        {
            self.btn1.selected = NO;
            self.btn2.selected = YES;
            self.btn3.selected = NO;
        }
            break;
        case 2:
        {
            self.btn1.selected = NO;
            self.btn2.selected = NO;
            self.btn3.selected = YES;
        }
            break;
        default:
            break;
    }
}

- (void)switchText
{
    if (self.isLuxury) {
        self.costLabel1.text = @"100 红音符";
        self.costLabel2.text = @"1000 红音符";
        self.costLabel3.text = @"10000 红音符";
        [self.btn1 setBackgroundImage:[UIImage imageNamed:@"cc_turntable_open_selected_luxury"] forState:UIControlStateSelected];
        [self.btn2 setBackgroundImage:[UIImage imageNamed:@"cc_turntable_open_selected_luxury"] forState:UIControlStateSelected];
        [self.btn3 setBackgroundImage:[UIImage imageNamed:@"cc_turntable_open_selected_luxury"] forState:UIControlStateSelected];
    } else {
        self.costLabel1.text = @"10 红音符";
        self.costLabel2.text = @"100 红音符";
        self.costLabel3.text = @"1000 红音符";
        [self.btn1 setBackgroundImage:[UIImage imageNamed:@"cc_turntable_open_selected_normal"] forState:UIControlStateSelected];
        [self.btn2 setBackgroundImage:[UIImage imageNamed:@"cc_turntable_open_selected_normal"] forState:UIControlStateSelected];
        [self.btn3 setBackgroundImage:[UIImage imageNamed:@"cc_turntable_open_selected_normal"] forState:UIControlStateSelected];
    }
}

- (void)setIsLuxury:(BOOL)isLuxury
{
    _isLuxury = isLuxury;
    
    [self switchText];
    [self switchOption:self.selectedIndex];
}

@end
