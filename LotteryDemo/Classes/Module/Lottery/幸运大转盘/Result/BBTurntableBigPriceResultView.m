//
//  BBTurntableBigPriceResultView.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "BBTurntableBigPriceResultView.h"

@interface BBTurntableBigPriceResultView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *giftImageView;
@property (weak, nonatomic) IBOutlet UILabel *giftNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *giftPriceLabel;

@property (nonatomic,strong) JFLotteryResultItem *model;

@end

@implementation BBTurntableBigPriceResultView

+ (void)showBigPriceWish:(JFLotteryResultItem *)model
{
    BBTurntableBigPriceResultView *view = [[NSBundle mainBundle]loadNibNamed:@"BBTurntableBigPriceResultView" owner:self options:nil][0];
    view.model = model;
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    view.alpha = 0;
    [UIView animateWithDuration:0.28 animations:^{
        view.alpha = 1;
    }];
    
    [view showAnimation];
}

- (void)showAnimation
{
    NSInteger circleNum = 1;
    CGFloat rotationRadian = 360 * (M_PI / 180.0) * circleNum;
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:rotationRadian];
    rotationAnimation.duration = 5;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.repeatCount = 1000;
    rotationAnimation.removedOnCompletion = NO;
    [self.bgImageView.layer addAnimation:rotationAnimation forKey:@"turntable-result-rotationAnimation"];
    
    self.giftNameLabel.text = self.model.itemName;
    self.giftPriceLabel.text = [NSString stringWithFormat:@"%ld", self.model.goldPrice];
    self.giftImageView.image = [UIImage imageNamed:self.model.picUrl];
    self.contentView.alpha = 1;
    self.contentView.transform = CGAffineTransformMakeScale(0, 0);
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.contentView.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

#pragma mark - Event
- (IBAction)onTapCover:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.contentView.alpha = 0;
        weakSelf.contentView.transform = CGAffineTransformMakeScale(0.05, 0.05);
        [weakSelf layoutIfNeeded];
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

@end
