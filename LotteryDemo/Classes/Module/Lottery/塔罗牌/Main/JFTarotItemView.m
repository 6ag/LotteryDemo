//
//  JFTarotItemView.m
//  VoiceChat
//
//  Created by feng on 2021/12/30.
//  Copyright © 2021 NoCardData. All rights reserved.
//

#import "JFTarotItemView.h"

@interface JFTarotItemView()

@end

@implementation JFTarotItemView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(-3, 1);
    self.layer.shadowOpacity = 0.2;
}

- (IBAction)onClickCard:(id)sender
{
    if (self.isAnimation) {
        return;
    }
    self.isAnimation = YES;
    
    if (self.onClickCard) {
        self.onClickCard(self);
    }
}

- (void)drawCardSuccessWithResultModel:(JFLotteryResultItem *)model
{
    self.frontImageView.image = [UIImage imageNamed:model.picUrl];
    [self animationToFront:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self animationToFront:NO];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isAnimation = NO;
        });
    });
}

- (void)drawCardFailure
{
    self.isAnimation = NO;
}

- (void)animationToFront:(BOOL)toFront
{
    UIViewAnimationOptions option = toFront ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight;
    [UIView transitionWithView:self duration:0.5 options:option animations:^{
        if (toFront) {
            self.frontImageView.hidden = NO;
            self.backImageView.hidden = YES;
        } else {
            self.frontImageView.hidden = YES;
            self.backImageView.hidden = NO;
        }
    } completion:^(BOOL finished) {
        
    }];
}

@end
