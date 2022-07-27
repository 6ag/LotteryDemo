//
//  HHTurntableAnimView.m
//  VoiceChat
//
//  Created by feng on 2021/3/27.
//  Copyright © 2021 NoCardData. All rights reserved.
//

#import "HHTurntableAnimView.h"
#import "JFHttpRequestHelper.h"

// 礼物视图数量，转盘分成多少格子
#define AVERAGE_COUNT 10

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface HHTurntableAnimView () <CAAnimationDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *turntableBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *turntableLightImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *turntableLightImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *turntableImageView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UIButton *goBtn;

@property (strong, nonatomic) NSMutableArray<JFLotteryResultItem *> *giftArray;

@property (nonatomic, assign) NSInteger circleAngle;

@property (nonatomic, strong) NSTimer *lightTimer;

@end

@implementation HHTurntableAnimView

- (void)dealloc
{
    [self destoryTimer];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self getTurntableGiftListData];
    [self setupStartBtnAnim];
}

- (void)setupLightAnimWithTimeInterval:(NSTimeInterval)seconds
{
    [self destoryTimer];
    
    self.turntableLightImageView1.hidden = !self.turntableLightImageView1.hidden;
    self.turntableLightImageView2.hidden = !self.turntableLightImageView2.hidden;
    
    @weakify(self);
    self.lightTimer = [NSTimer timerWithTimeInterval:seconds block:^(NSTimer * _Nonnull timer) {
        @strongify(self);
        self.turntableLightImageView1.hidden = !self.turntableLightImageView1.hidden;
        self.turntableLightImageView2.hidden = !self.turntableLightImageView2.hidden;
    } repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.lightTimer forMode:NSRunLoopCommonModes];
}

- (void)setupStartBtnAnim
{
    CABasicAnimation *scaleAnimate = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimate.duration = 0.8;
    scaleAnimate.repeatCount = HUGE_VALF;
    scaleAnimate.beginTime = CACurrentMediaTime() + 0.8;
    scaleAnimate.autoreverses = YES;
    scaleAnimate.removedOnCompletion = YES;
    scaleAnimate.fillMode=kCAFillModeForwards;
    scaleAnimate.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimate.toValue = [NSNumber numberWithFloat:1.2];
    scaleAnimate.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [self.goBtn.layer addAnimation:scaleAnimate forKey:@"scale-layer"];
}

- (void)stopStartBtnAnim
{
    [self.goBtn.layer removeAllAnimations];
}

#pragma mark - UI
/// 配置转盘上的礼物视图
- (void)setupTurntableGiftView
{
    [self.turntableImageView removeAllSubviews];
    [self layoutIfNeeded];
    
    CGRect bounds = self.turntableImageView.bounds;
    
    // 圆心
    CGPoint center = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5);
    // 礼物图片半径，圆心到图片中心的距离
    CGFloat giftImageRadius = bounds.size.width * 0.31;
    // 礼物价格半径，圆心到图片中心的距离
    CGFloat giftPriceRadius = bounds.size.width * 0.43;
    // 礼物图片宽度
    CGFloat giftImageWidth = bounds.size.width * 0.13;
    
    for (int i = 0; i < self.giftArray.count; i++) {
        CGFloat perRadian = 2 * M_PI / AVERAGE_COUNT;
        CGFloat radian = perRadian * i + perRadian * 0.5;
        CGFloat offsetRadian = radian - perRadian * 2.5;
        
        UIImageView *giftImageView = [[UIImageView alloc] init];
        giftImageView.frame = CGRectMake(0, 0, giftImageWidth, giftImageWidth);
        giftImageView.center = CGPointMake(center.x + giftImageRadius * cos(offsetRadian), center.y + giftImageRadius * sin(offsetRadian));
        giftImageView.transform = CGAffineTransformMakeRotation(radian);
        
        UILabel *giftNameLabel = [[UILabel alloc] init];
        giftNameLabel.textAlignment = NSTextAlignmentCenter;
        giftNameLabel.font = JFFontPingFangSCMedium(11);
        giftNameLabel.textColor = UIColorHex(#7EDBFF);
        
        giftNameLabel.frame = CGRectMake(0, 0, 100, 20);
        giftNameLabel.center = CGPointMake(center.x + giftPriceRadius * cos(offsetRadian), center.y + giftPriceRadius * sin(offsetRadian));
        giftNameLabel.transform = CGAffineTransformMakeRotation(radian);
        
        // 这里 -90° 是因为iOS默认0°是指向3点钟方向，而不是正上方
        self.giftArray[i].angle = (360 - (int)RADIANS_TO_DEGREES(offsetRadian) - 90) % 360;
        
        giftImageView.image = [UIImage imageNamed:self.giftArray[i].picUrl];
        [self.turntableImageView addSubview:giftImageView];
        
        giftNameLabel.text = [NSString stringWithFormat:@"%ld", self.giftArray[i].goldPrice];
        [self.turntableImageView addSubview:giftNameLabel];
    }
}

#pragma mark - Event
/// 点击GO
- (IBAction)onClickGoBtn:(id)sender
{
    if (self.isAnimation) {
        return;
    }
    self.isAnimation = YES;
    self.goBtn.userInteractionEnabled = NO;
    
    // 回调点击事件
    if (self.tapGoBtnBlock) {
        if (self.animStatus) {
            self.tapGoBtnBlock();
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.tapGoBtnBlock();
            });
        }
    }
    
    // 只有高级转盘，才能跳过动画
    if (self.animStatus) {
        return;
    }
    [self setupLightAnimWithTimeInterval:0.5];
    [self stopStartBtnAnim];
    
    NSInteger circleNum = 1000;
    // 计算旋转弧度
    CGFloat rotationRadian = 360 * (M_PI / 180.0) * circleNum;
    
    CAMediaTimingFunction *timingFunc = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self startRotationAnimationWithRadian:rotationRadian
                                  duration:circleNum * 0.3
                            timingFunction:timingFunc
                                  delegate:nil];
}

// 生成随机整数
- (int)getRandomInt:(int)from to:(int)to {
    return (int)(from + (arc4random() % (to - from + 1)));
}

// 生成随机浮点数
- (float)getRandomFloat:(float)from to:(float)to {
    float diff = to - from;
    return (((float) arc4random() / UINT_MAX) * diff) + from;
}

/// 在指定礼物处停下
/// @param giftName 礼物名称
- (void)stopAtGiftName:(NSString *)giftName
{
    // 只有高级转盘，才能跳过动画
    if (self.animStatus) {
        if (self.animStopBlock) {
            self.animStopBlock();
        }
        
        self.isAnimation = NO;
        self.goBtn.userInteractionEnabled = YES;
        return;
    }
    
    int randomAngle = 0;
    while (true) {
        randomAngle = [self getRandomInt:-13 to:13];
        if (randomAngle > 5 || randomAngle < -5) {
            NSLog(@"randomAngle = %d", randomAngle);
            break;
        }
    }
    
    BOOL isExists = NO;
    for (JFLotteryResultItem *model in self.giftArray) {
        if ([giftName isEqualToString:model.itemName]) {
            _circleAngle = model.angle + randomAngle;
            isExists = YES;
            break;
        }
    }
    // 礼物不存在转盘里，就不指向任何礼物
    if (!isExists) {
        _circleAngle = 0;
    }
    
    // 转圈的圈数
    NSInteger circleNum = 4;
    
    // 计算旋转弧度
    CGFloat rotationRadian = 360 * (M_PI / 180.0) * circleNum + _circleAngle * (M_PI / 180.0);
    
    CAMediaTimingFunction *timingFunc = [CAMediaTimingFunction functionWithControlPoints:0.00 :0.14 :0.00 :1.00];
    [self startRotationAnimationWithRadian:rotationRadian
                                  duration:8
                            timingFunction:timingFunc
                                  delegate:self];
}

/// 停止动画
- (void)stopOfFailure
{
    // 偏移，不指向任何礼物
    _circleAngle = 0;
    
    // 转圈的圈数
    NSInteger circleNum = 1;
    // 计算旋转弧度，
    CGFloat rotationRadian = 360 * (M_PI / 180.0) * circleNum + _circleAngle * (M_PI / 180.0);
    
    CAMediaTimingFunction *timingFunc = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self startRotationAnimationWithRadian:rotationRadian
                                  duration:circleNum * 0.3
                            timingFunction:timingFunc
                                  delegate:self];
    
    
}

- (void)startRotationAnimationWithRadian:(CGFloat)radian
                                duration:(CGFloat)duration
                          timingFunction:(CAMediaTimingFunction *)timingFunction
                                delegate:(id<CAAnimationDelegate>)delegate
{
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:radian];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.delegate = delegate;
    rotationAnimation.timingFunction = timingFunction;
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.removedOnCompletion = NO;
    [self.turntableImageView.layer addAnimation:rotationAnimation forKey:@"turntable-rotationAnimation"];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self setupLightAnimWithTimeInterval:0.1];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self destoryTimer];
        if (self.animStopBlock) {
            self.animStopBlock();
        }
        
        self.isAnimation = NO;
        self.goBtn.userInteractionEnabled = YES;
        [self setupStartBtnAnim];
    });
}

/// 销毁定时器
- (void)destoryTimer
{
    if (self.lightTimer) {
        [self.lightTimer invalidate];
        self.lightTimer = nil;
    }
}

#pragma mark - 网络
/// 获取转盘礼物数据
- (void)getTurntableGiftListData
{
    self.giftArray = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    [JFHttpRequestHelper getWishListWithSuccess:^(id  _Nonnull data) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.giftArray appendObjects:[data copy]];
            while (weakSelf.giftArray.count > AVERAGE_COUNT) {
                [weakSelf.giftArray removeObjectAtIndex:0];
            }
            [weakSelf setupTurntableGiftView];
        });
    } failure:^(NSNumber * _Nonnull code, NSString * _Nonnull msg) {
        [weakSelf setupTurntableGiftView];
        [MBProgressHUD showError:msg];
    }];
}

@end
