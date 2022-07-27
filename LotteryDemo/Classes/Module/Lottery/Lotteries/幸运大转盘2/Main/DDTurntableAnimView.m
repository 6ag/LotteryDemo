//
//  DDTurntableAnimView.m
//  VoiceChat
//
//  Created by feng on 2021/3/27.
//  Copyright © 2021 NoCardData. All rights reserved.
//

#import "DDTurntableAnimView.h"
#import "JFHttpRequestHelper.h"

// 礼物视图数量，转盘分成多少格子
#define AVERAGE_COUNT 12

// 速度
#define SPEED 0.3

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface DDTurntableAnimView () <CAAnimationDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *turntableBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *turntableImageView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UIButton *goBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top_turntableImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_turntableImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *left_turntableImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *right_turntableImageView;

@property (strong, nonatomic) NSMutableArray<JFLotteryResultItem *> *giftArray;
@property (strong, nonatomic) NSMutableArray<JFLotteryResultItem *> *giftArray1;

@property (nonatomic, assign) BOOL isAnimation;
@property (nonatomic, assign) NSInteger circleAngle;

@property (nonatomic, strong) CADisplayLink *link;

@property (nonatomic, assign) CGFloat rotationRadian;
@property (nonatomic, assign) CGFloat totalRotationRadian;

@end

@implementation DDTurntableAnimView

- (void)dealloc
{
    [self destoryLink];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupRotationImageView];
    [self getTurntableGiftListData];
}

- (void)setupRotationImageView
{
    self.top_turntableImageView.constant = JFWidthRadio(25);
    self.bottom_turntableImageView.constant = JFWidthRadio(25);
    self.left_turntableImageView.constant = JFWidthRadio(25);
    self.right_turntableImageView.constant = JFWidthRadio(25);
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
    CGFloat giftImageRadius = bounds.size.width * 0.33;
    // 礼物价格半径，圆心到图片中心的距离
    CGFloat giftPriceRadius = bounds.size.width * 0.43;
    // 礼物图片宽度
    CGFloat giftImageWidth = bounds.size.width * 0.13;
    
    for (int i = 0; i < self.giftArray.count; i++) {
        
        // 默认偏移-2.5格，第一个礼物从最顶部开始顺时针布局
        CGFloat radian = 2 * M_PI / AVERAGE_COUNT * i + 2 * M_PI / AVERAGE_COUNT * 0.5;
        CGFloat offsetRadian = radian - 2 * M_PI / AVERAGE_COUNT * 3;
        
        UIImageView *giftImageView = [[UIImageView alloc] init];
        giftImageView.frame = CGRectMake(0, 0, giftImageWidth, giftImageWidth);
        giftImageView.center = CGPointMake(center.x + giftImageRadius * cos(offsetRadian), center.y + giftImageRadius * sin(offsetRadian));
        giftImageView.transform = CGAffineTransformMakeRotation(radian);
        
        UILabel *giftNameLabel = [[UILabel alloc] init];
        giftNameLabel.textAlignment = NSTextAlignmentCenter;
        giftNameLabel.font = [UIFont systemFontOfSize:12];
        giftNameLabel.textColor = UIColorHex(#FFDD82);
        giftNameLabel.frame = CGRectMake(0, 0, 100, 20);
        giftNameLabel.center = CGPointMake(center.x + giftPriceRadius * cos(offsetRadian), center.y + giftPriceRadius * sin(offsetRadian));
        giftNameLabel.transform = CGAffineTransformMakeRotation(radian);
        
        // 这里 -90° 是因为iOS默认0°是指向3点钟方向，而不是正上方
        self.giftArray[i].angle = (360 - (int)RADIANS_TO_DEGREES(offsetRadian) - 90) % 360;
        
        NSLog(@"名称=%@, 自身旋转弧度 = %.2f, 礼物在转盘的弧度 = %.2f, 转动 %ld 角度可以让指针指向礼物", self.giftArray[i].itemName, radian, offsetRadian, self.giftArray[i].angle);
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
        self.tapGoBtnBlock();
    }
    
    if (self.animStatus) {
        return;
    }
    
    // 让转盘永久转下去，等接口回调后，再计算停留位置
    // 转圈的圈数，设置一个大点的数值，保证转盘可以一直转下去 100 就是50秒
    NSInteger circleNum = 10000;
    // 计算旋转弧度
    CGFloat rotationRadian = 360 * (M_PI / 180.0) * circleNum;
    
    [self destoryLink];
    self.totalRotationRadian = rotationRadian;
    self.rotationRadian = rotationRadian;
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(rotationAnimation)];
    [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
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
    NSInteger circleNum = 5;
    // 计算旋转弧度
    CGFloat rotationRadian = 360 * (M_PI / 180.0) * circleNum + _circleAngle * (M_PI / 180.0);
    
    [self destoryLink];
    self.turntableImageView.transform = CGAffineTransformIdentity;
    
    self.totalRotationRadian = rotationRadian;
    self.rotationRadian = rotationRadian;
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(rotationAnimation)];
    [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)rotationAnimation
{
    CGFloat per = self.rotationRadian / self.totalRotationRadian;
    CGFloat perAngle = per * SPEED; // 最大速度
    perAngle = MAX(0.002, perAngle); // 最小速度
    if (self.rotationRadian >= perAngle) {
        self.rotationRadian -= perAngle;
    }
    if (self.rotationRadian <= perAngle) {
        [self destoryLink];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.animStopBlock) {
                self.animStopBlock();
            }
            
            self.isAnimation = NO;
            self.goBtn.userInteractionEnabled = YES;
        });
    }
    self.turntableImageView.transform = CGAffineTransformRotate(self.turntableImageView.transform, perAngle);
}

/// 停止动画
- (void)stopOfFailure
{
    [self destoryLink];
    self.turntableImageView.transform = CGAffineTransformIdentity;
    self.isAnimation = NO;
    self.goBtn.userInteractionEnabled = YES;
}

/// 销毁定时器
- (void)destoryLink
{
    if (self.link) {
        [self.link invalidate];
        self.link = nil;
    }
}

#pragma mark - 网络
/// 获取转盘礼物数据
- (void)getTurntableGiftListData
{
    // 先加载内存中的礼物数据
    if (self.giftArray1 && self.giftArray1.count > 0) {
        self.giftArray = [self.giftArray1 mutableCopy];
        [self setupTurntableGiftView];
        return;
    }
    
    self.giftArray = [NSMutableArray array];
    
    __weak typeof(self)weakSelf = self;
    [JFHttpRequestHelper getWishListWithSuccess:^(id  _Nonnull data) {
        
        [weakSelf.giftArray appendObjects:[data copy]];
        
        // 转盘可以显示10个礼物，展示接口返回来的后10个数据。
        while (weakSelf.giftArray.count > AVERAGE_COUNT) {
            [weakSelf.giftArray removeObjectAtIndex:0];
        }
        weakSelf.giftArray1 = [weakSelf.giftArray mutableCopy];
        
        [weakSelf setupTurntableGiftView];
    } failure:^(NSNumber * _Nonnull code, NSString * _Nonnull msg) {
        [weakSelf setupTurntableGiftView];
        [MBProgressHUD showError:msg];
    }];
}

@end
