//
//  DDTurntableOptionView.m
//  VoiceChat
//
//  Created by feng on 2021/1/13.
//  Copyright © 2021 NoCardData. All rights reserved.
//

#import "DDTurntableOptionView.h"

@interface DDTurntableOptionView ()

@property (weak, nonatomic) IBOutlet UILabel *costLabel1;
@property (weak, nonatomic) IBOutlet UILabel *costLabel2;
@property (weak, nonatomic) IBOutlet UILabel *costLabel3;

@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UIButton *btn3;

@end

@implementation DDTurntableOptionView

- (void)awakeFromNib
{
    [super awakeFromNib];
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

@end
