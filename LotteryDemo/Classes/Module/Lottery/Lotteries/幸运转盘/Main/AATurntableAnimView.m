//
//  AATurntableAnimView.m
//  VoiceChat
//
//  Created by feng on 2021/3/27.
//  Copyright © 2021 NoCardData. All rights reserved.
//

#import "AATurntableAnimView.h"
#import "JFHttpRequestHelper.h"

// 礼物视图数量，转盘分成多少格子
#define AVERAGE_COUNT 10

// 速度
#define SPEED 0.5

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface AATurntableAnimView () <CAAnimationDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *circleImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *circleImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *turntableImageView;
@property (weak, nonatomic) IBOutlet UIButton *goBtn;

@property (strong, nonatomic) NSMutableArray<JFLotteryResultItem *> *giftArray;

@property (nonatomic, assign) BOOL isAnimation;
@property (nonatomic, assign) NSInteger circleAngle;

@end

@implementation AATurntableAnimView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self getTurntableGiftListData];
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
    CGFloat giftImageRadius = bounds.size.width * 0.35;
    // 礼物图片宽度
    CGFloat giftImageWidth = bounds.size.width * 0.16;
    
    for (int i = 0; i < self.giftArray.count; i++) {
        // 默认偏移-2.5格，第一个礼物从最顶部开始顺时针布局
        CGFloat radian = 2 * M_PI / AVERAGE_COUNT * i;
        CGFloat offsetRadian = radian - 2 * M_PI / AVERAGE_COUNT * 2.5;
  
        UIImageView *giftImageView = [[UIImageView alloc] init];
        giftImageView.frame = CGRectMake(0, 0, giftImageWidth, giftImageWidth);
        giftImageView.center = CGPointMake(center.x + giftImageRadius * cos(offsetRadian),
                                       center.y + giftImageRadius * sin(offsetRadian));
        giftImageView.transform = CGAffineTransformMakeRotation(radian);
        
        self.giftArray[i].angle = (360 - (int)RADIANS_TO_DEGREES(offsetRadian)) % 360;
        
        NSLog(@"名称=%@, 自身旋转弧度 = %.2f, 礼物在转盘的弧度 = %.2f, 转动 %ld 角度可以让指针指向礼物", self.giftArray[i].itemName, radian, offsetRadian, self.giftArray[i].angle);
        
        giftImageView.image = [UIImage imageNamed:self.giftArray[i].picUrl];
        [self.turntableImageView addSubview:giftImageView];
    }
}

#pragma mark - Event
/// 点击GO
- (IBAction)onClickGoBtn:(id)sender
{
    if (_isAnimation) {
        return;
    }
    _isAnimation = YES;
    self.goBtn.userInteractionEnabled = NO;
    
    // 回调点击事件
    if (self.tapGoBtnBlock) {
        self.tapGoBtnBlock();
    }
    
    // 让转盘永久转下去，等接口回调后，再计算停留位置
    // 转圈的圈数，设置一个大点的数值，保证转盘可以一直转下去 100 就是50秒
    NSInteger circleNum = 1000;
    // 计算旋转弧度
    CGFloat rotationRadian = 360 * (M_PI / 180.0) * circleNum;
    
    [self startRotationAnimationWithRadian:rotationRadian
                                  duration:circleNum * SPEED
                        timingFunctionName:kCAMediaTimingFunctionLinear
                                  delegate:nil];
}

/// 在指定礼物处停下
/// @param giftName 礼物名称
- (void)stopAtGiftName:(NSString *)giftName
{
    BOOL isExists = NO;
    for (JFLotteryResultItem *model in self.giftArray) {
        if ([giftName isEqualToString:model.itemName]) {
            _circleAngle = model.angle;
            isExists = YES;
            break;
        }
    }
    // 礼物不存在转盘里，就不指向任何礼物
    if (!isExists) {
        _circleAngle = 0;
    }
    
    // 转圈的圈数
    NSInteger circleNum = 3;
    // 计算旋转弧度
    CGFloat rotationRadian = 360 * (M_PI / 180.0) * circleNum + _circleAngle * (M_PI / 180.0);
    
    [self startRotationAnimationWithRadian:rotationRadian
                                  duration:circleNum * SPEED
                        timingFunctionName:kCAMediaTimingFunctionEaseOut
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
    
    [self startRotationAnimationWithRadian:rotationRadian
                                  duration:circleNum * SPEED
                        timingFunctionName:kCAMediaTimingFunctionEaseOut
                                  delegate:self];
}

- (void)startRotationAnimationWithRadian:(CGFloat)radian
                                duration:(CGFloat)duration
                      timingFunctionName:(CAMediaTimingFunctionName)timingFunctionName
                                delegate:(id<CAAnimationDelegate>)delegate
{
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:radian];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.delegate = delegate;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:timingFunctionName];
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.removedOnCompletion = NO;
    [self.turntableImageView.layer addAnimation:rotationAnimation forKey:@"turntable-rotationAnimation"];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    // 动画停止回调
    if (self.animStopBlock) {
        self.animStopBlock();
    }
    
    _isAnimation = NO;
    self.goBtn.userInteractionEnabled = YES;
}

#pragma mark - 网络
/// 获取转盘礼物数据
- (void)getTurntableGiftListData
{
    self.giftArray = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    [JFHttpRequestHelper getWishListWithSuccess:^(id  _Nonnull data) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.giftArray appendObjects:data];
            
            // 转盘可以显示10个礼物，展示接口返回来的后10个数据。
            while (weakSelf.giftArray.count > 10) {
                [weakSelf.giftArray removeObjectAtIndex:0];
            }
            
            [weakSelf setupTurntableGiftView];
        });
    } failure:^(NSNumber * _Nonnull code, NSString * _Nonnull msg) {
        [MBProgressHUD showError:msg];
    }];
}

@end
