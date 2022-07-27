//
//  FFTurntableOptionView.m
//  VoiceChat
//
//  Created by feng on 2021/1/13.
//  Copyright © 2021 NoCardData. All rights reserved.
//

#import "FFTurntableOptionView.h"

@interface FFTurntableOptionView ()

@property (weak, nonatomic) IBOutlet UIButton *optionBtn1;
@property (weak, nonatomic) IBOutlet UIButton *optionBtn2;
@property (weak, nonatomic) IBOutlet UIButton *optionBtn3;

@end

@implementation FFTurntableOptionView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self switchOption:0];
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
            self.optionBtn1.selected = YES;
            self.optionBtn2.selected = NO;
            self.optionBtn3.selected = NO;
        }
            break;
        case 1:
        {
            self.optionBtn1.selected = NO;
            self.optionBtn2.selected = YES;
            self.optionBtn3.selected = NO;
        }
            break;
        case 2:
        {
            self.optionBtn1.selected = NO;
            self.optionBtn2.selected = NO;
            self.optionBtn3.selected = YES;
        }
            break;
        default:
            break;
    }
}

@end
