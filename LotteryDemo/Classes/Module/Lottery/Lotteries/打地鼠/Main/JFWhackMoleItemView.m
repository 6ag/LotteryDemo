//
//  JFWhackMoleItemView.m
//  VoiceChat
//
//  Created by feng on 2021/12/30.
//  Copyright © 2021 NoCardData. All rights reserved.
//

#import "JFWhackMoleItemView.h"
#import "YYAnimatedImageView.h"
#import "YYImage.h"

typedef enum : NSUInteger {
    MouseStatusNone, // 还未出现老鼠
    MouseStatusNormal, // 老鼠正在蹦跶
    MouseStatusStun, // 老鼠被击晕
    MouseStatusDead, // 老鼠被打死了
} MouseStatus;

@interface JFWhackMoleItemView()

@property (weak, nonatomic) IBOutlet YYAnimatedImageView *mouseImageView;

@property (weak, nonatomic) IBOutlet UIView *effectStunView;
@property (weak, nonatomic) IBOutlet UIImageView *effectHammerImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_MouseImageView;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) MouseStatus mouseStatus; // 老鼠的状态

@end

@implementation JFWhackMoleItemView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.mouseStatus = MouseStatusNone;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((arc4random_uniform(10) + 1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self timerAction];
        [self startTimer];
    });
}

- (void)dealloc
{
    [self cancelTimer];
}

/// 随机5-10秒定时执行一次
- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:arc4random_uniform(5) + 6 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

/// 释放定时器
- (void)cancelTimer
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - Event
/// 固定时间执行
- (void)timerAction
{
    if (self.mouseStatus == MouseStatusNone) {
        self.mouseType = arc4random_uniform(4) + 1;
        NSString *normalImageName = [NSString stringWithFormat:@"whack_mole_open_item_%ld_normal", self.mouseType];
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:normalImageName ofType:@"gif"]];
        self.mouseImageView.image = [YYImage imageWithData:data];
        
        [self showMouse];
    } else {
        [self hideMouse];
    }
}

/// 显示老鼠
- (void)showMouse
{
    self.mouseImageView.alpha = 1;
    self.bottom_MouseImageView.constant = JFWidthRadio(120);
    [self layoutIfNeeded];
    [UIView animateWithDuration:1.25 animations:^{
        self.bottom_MouseImageView.constant = JFWidthRadio(35);
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.mouseStatus = MouseStatusNormal;
        self->_isClickable = YES;
    }];
}

/// 隐藏老鼠
- (void)hideMouse
{
    self.bottom_MouseImageView.constant = JFWidthRadio(35);
    [self layoutIfNeeded];
    [UIView animateWithDuration:1.25 animations:^{
        self.bottom_MouseImageView.constant = JFWidthRadio(120);
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        // 隐藏未打死的老鼠后，重置定时器
        self.mouseStatus = MouseStatusNone;
        [self cancelTimer];
        [self startTimer];
    }];
}

/// 击打动画
- (void)hitAnim
{
    self.effectHammerImageView.alpha = 1;
    self.effectHammerImageView.layer.anchorPoint = CGPointMake(1, 1);
    self.effectHammerImageView.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
    self.effectStunView.alpha = 0;
    self.effectStunView.transform = CGAffineTransformIdentity;
    
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.effectHammerImageView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.effectHammerImageView.alpha = 0;
            self.effectStunView.alpha = 0.5;
            self.effectStunView.transform = CGAffineTransformMakeScale(2, 2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                self.effectStunView.alpha = 0;
            } completion:^(BOOL finished) {
                self->_isClickable = YES;
            }];
        }];
    }];
}

- (IBAction)onClickCard:(id)sender
{
    if (self.mouseStatus == MouseStatusNone || self.mouseStatus == MouseStatusDead) {
        return;
    }
    
    if (!_isClickable) {
        return;
    }
    _isClickable = NO;
    
    if (self.onClickCard) {
        self.onClickCard(self);
    }
}

- (void)drawCardSuccessWithResultModel:(JFLotteryResultItem *)model
{
    [self hitAnim];
    
    if (model.giftId == 55) {
        NSString *normalImageName = [NSString stringWithFormat:@"whack_mole_open_item_%ld_stun", self.mouseType];
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:normalImageName ofType:@"gif"]];
        self.mouseImageView.image = [YYImage imageWithData:data];
        
        self.mouseStatus = MouseStatusStun;
    } else {
        NSString *normalImageName = [NSString stringWithFormat:@"whack_mole_open_item_%ld_dead", self.mouseType];
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:normalImageName ofType:@"png"]];
        self.mouseImageView.image = [YYImage imageWithData:data];
        
        self.mouseStatus = MouseStatusDead;
        
        // 关闭定时器
        [self cancelTimer];
        
        // 隐藏老鼠
        [UIView animateWithDuration:0.25 delay:0.25 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.mouseImageView.alpha = 0;
        } completion:^(BOOL finished) {
            self.mouseStatus = MouseStatusNone;
            
            // 重新打开定时器
            [self startTimer];
        }];
    }
}

- (void)drawCardFailure
{
    _isClickable = YES;
}

- (void)setType:(NSInteger)type
{
    _type = type;

    self.effectHammerImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"whack_mole_open_option_hammer_%ld", type]];
}

@end
