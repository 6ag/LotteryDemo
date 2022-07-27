//
//  JFMakeCandyView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFMakeCandyView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "JFMakeCandyResultView.h"
#import "JFMakeCandyBallView.h"

#define CONTENT_VIEW_HEIGHT (kScreenWidth/(375.0/534.0))

@interface JFMakeCandyView ()

@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn1;
@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn2;
@property (weak, nonatomic) IBOutlet UIImageView *titleSelectView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerX_titleSelectView;

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIImageView *turntableImageView;
@property (weak, nonatomic) IBOutlet UIView *ballContainerView;

@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;

@property (weak, nonatomic) IBOutlet UILabel *priceTipLabel;
@property (weak, nonatomic) IBOutlet UIButton *optionBtn1;
@property (weak, nonatomic) IBOutlet UIButton *optionBtn2;
@property (weak, nonatomic) IBOutlet UIButton *optionBtn3;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_contentView;

@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;

@property (nonatomic, assign) BOOL isAnimation;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, assign) BOOL isLuxury;

/// 当前选中下标，0、1、2
@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@end

@implementation JFMakeCandyView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupBgView:self.contentView rect:CGRectMake(0, 0, kScreenWidth, CONTENT_VIEW_HEIGHT)];
}

- (void)setupBgView:(UIView *)view rect:(CGRect)rect
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(15, 15)];
    CAShapeLayer * maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = rect;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

+ (void)show
{
    JFMakeCandyView *view = [[NSBundle mainBundle] loadNibNamed:@"JFMakeCandyView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];

    view.dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:view.ballContainerView];
    
    view.coverView.alpha = 0;
    view.bottom_contentView.constant = -CONTENT_VIEW_HEIGHT;
    [view layoutIfNeeded];
    [UIView animateWithDuration:0.28 animations:^{
        view.coverView.alpha = 1;
        view.bottom_contentView.constant = (iPhoneX ? 0 : -20);
        [view layoutIfNeeded];
    } completion:^(BOOL finished) {
        view.isLuxury = NO;
    }];
}

- (void)closeDialog
{
    [UIView animateWithDuration:0.28 animations:^{
        self.coverView.alpha = 0;
        self.bottom_contentView.constant = -CONTENT_VIEW_HEIGHT;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Event
- (IBAction)onClickNormalBtn:(id)sender
{
    self.isLuxury = NO;
    
    self.navSwitchBtn1.selected = YES;
    self.navSwitchBtn2.selected = NO;
    
    [self setSelBarAnimation:0];
}

- (IBAction)onClickLuxuryBtn:(id)sender
{
    self.isLuxury = YES;
    
    self.navSwitchBtn1.selected = NO;
    self.navSwitchBtn2.selected = YES;
    
    [self setSelBarAnimation:1];
}

/// 自定义导航栏上的指示器滚动动画
- (void)setSelBarAnimation:(NSInteger)index
{
    [self.contentView layoutIfNeeded];
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.28 animations:^{
        if (index == 0) {
            weakSelf.centerX_titleSelectView.constant = 0;
        } else if (index == 1) {
            weakSelf.centerX_titleSelectView.constant = weakSelf.navSwitchBtn2.centerX - weakSelf.navSwitchBtn1.centerX;
        }
        [weakSelf.contentView layoutIfNeeded];
    }];
}

/// 关闭视图
- (IBAction)onClickCloseBtn:(id)sender
{
    [self closeDialog];
}

// 奖品
- (IBAction)onClickGiftBtn:(id)sender
{
    
}

/// 记录
- (IBAction)onClickRecordBtn:(id)sender
{
    
}

/// 排行
- (IBAction)onClickRankBtn:(id)sender
{
    
}

/// 规则
- (IBAction)onClickRuleBtn:(id)sender
{
    
}

/// 红音符充值
- (IBAction)onClickCoinBtn:(id)sender
{
    
}

// 1次
- (IBAction)onClickOptionBtn1:(id)sender {
    [self openWishAction:1];
}

// 10次
- (IBAction)onClickOptionBtn2:(id)sender {
    [self openWishAction:2];
}

// 100次
- (IBAction)onClickOptionBtn3:(id)sender {
    [self openWishAction:5];
}

#pragma mark - Network
- (void)openWishAction:(NSInteger)type
{
    if (self.isRequesting) {
        return;
    }
    self.isRequesting = YES;
    [self openBoxBehavior];
    
    __weak typeof(self) weakSelf = self;
    [JFHttpRequestHelper wish:type success:^(id data) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.isRequesting = NO;
            weakSelf.models = data;
         
            // 弹出结果视图
            if (weakSelf.models) {
                [JFMakeCandyResultView showWish:weakSelf.models];
                weakSelf.models = nil;
            }
            
            [weakSelf idleAnimationBehavior];
        });
    } failure:^(NSNumber *code, NSString *msg) {
        weakSelf.isRequesting = NO;
        [weakSelf idleAnimationBehavior];
        [MBProgressHUD showError:msg];
    }];
}

/// 配置转盘上的礼物视图
- (void)setupMakeCandyGiftView
{
    [self layoutIfNeeded];
    [self.ballContainerView removeAllSubviews];
    
    CGFloat ballWidth;
    CGFloat ballHeight;
    NSInteger count;
    if (self.isLuxury) {
        count = 6;
        ballWidth = 96;
        ballHeight = 77;
    } else {
        count = 7;
        ballWidth = 78;
        ballHeight = 62;
    }

    for (int i = 0; i < count; i++) {
        JFMakeCandyBallView *containerView = [[JFMakeCandyBallView alloc] initWithFrame:CGRectMake(0, 0, ballHeight * 0.9, ballHeight * 0.9)];
        containerView.collisionBoundsType = UIDynamicItemCollisionBoundsTypeEllipse;
        
        UIImageView *lightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 55, 55)];
        lightImageView.image = [UIImage imageNamed:@"make_candy_open_gift_light"];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.fromValue = [NSNumber numberWithFloat:0.2];
        animation.toValue = [NSNumber numberWithFloat:1.0];
        animation.duration = 0.8;
        animation.repeatCount = HUGE_VALF;
        animation.autoreverses = YES;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        [lightImageView.layer addAnimation:animation forKey:nil];
        
        NSString *ballImageName = @"";
        if (self.isLuxury) {
            ballImageName = [NSString stringWithFormat:@"make_candy_open_gift_%ld_luxury", i % count + 1];
        } else {
            ballImageName = [NSString stringWithFormat:@"make_candy_open_gift_%ld_normal", i % count + 1];
        }
        UIImageView *ballImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:ballImageName]];
        ballImageView.frame = CGRectMake(0, 0, ballWidth, ballHeight);
        ballImageView.center = containerView.center;
        
        [self.ballContainerView addSubview:containerView];
        [containerView addSubview:ballImageView];
        [containerView addSubview:lightImageView];
        
        switch (i) {
            case 0:
                containerView.center = CGPointMake(self.ballContainerView.width * 0.15, 110);
                break;
            case 1:
                containerView.center = CGPointMake(self.ballContainerView.width * 0.35, 110);
                break;
            case 2:
                containerView.center = CGPointMake(self.ballContainerView.width * 0.55, 110);
                break;
            case 3:
                containerView.center = CGPointMake(self.ballContainerView.width * 0.75, 110);
                break;
            case 4:
                containerView.center = CGPointMake(self.ballContainerView.width * 0.4, 40);
                break;
            case 5:
                containerView.center = CGPointMake(self.ballContainerView.width * 0.6, 40);
                break;
            case 6:
                containerView.center = CGPointMake(self.ballContainerView.width * 0.8, 40);
                break;
            default:
                break;
        }
    }
    
    self.ballContainerView.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.ballContainerView.alpha = 1;
    }];
    [self idleAnimationBehavior];
}

// 闲置动画
- (void)idleAnimationBehavior
{
    if (self.dynamicAnimator.behaviors.count > 0) {
        [self.dynamicAnimator removeAllBehaviors];
    }
    
    // 重力
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:self.ballContainerView.subviews];
    gravity.magnitude = 1;
    [self.dynamicAnimator addBehavior:gravity];
    
    // 碰撞
    UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:self.ballContainerView.subviews];
    collision.collisionMode = UICollisionBehaviorModeEverything;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.ballContainerView.bounds];
    [collision addBoundaryWithIdentifier:@"collisionPath" forPath:path];
    [self.dynamicAnimator addBehavior:collision];
    
    // 推力
    UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:self.ballContainerView.subviews mode:UIPushBehaviorModeInstantaneous];
    // x正右负左  y正下负上
    push.pushDirection = CGVectorMake(0, 1);
    push.magnitude = 0.3;
    push.active = YES;
    [self.dynamicAnimator addBehavior:push];
    
    UIDynamicItemBehavior *item = [[UIDynamicItemBehavior alloc] initWithItems:self.ballContainerView.subviews];
    item.elasticity = 0.5;
    [self.dynamicAnimator addBehavior:item];
}

// 推力摇奖
- (void)openBoxBehavior
{
    if (self.dynamicAnimator.behaviors.count > 0) {
        [self.dynamicAnimator removeAllBehaviors];
    }
    
    // 重力
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:self.ballContainerView.subviews];
    gravity.magnitude = 0.5;
    [self.dynamicAnimator addBehavior:gravity];
    
    // 碰撞
    UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:self.ballContainerView.subviews];
    collision.collisionMode = UICollisionBehaviorModeEverything;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.ballContainerView.bounds];
    [collision addBoundaryWithIdentifier:@"collisionPath" forPath:path];
    [self.dynamicAnimator addBehavior:collision];
    
    for (int i = 0; i < self.ballContainerView.subviews.count; i++) {
        // 推力
        UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[self.ballContainerView.subviews[i]] mode:UIPushBehaviorModeInstantaneous];
        [push setTargetOffsetFromCenter:UIOffsetMake(5 + 5 * i, 0) forItem:self.ballContainerView.subviews[0]];
        // x正右负左  y正下负上
        push.pushDirection = CGVectorMake(i % 2 == 0 ? 1 : -1, -1);
        push.angle = M_PI / self.ballContainerView.subviews.count * (arc4random() % 6);
        push.magnitude = 5;
        push.active = YES;
        [self.dynamicAnimator addBehavior:push];
    }
    
    UIDynamicItemBehavior *item = [[UIDynamicItemBehavior alloc] initWithItems:self.ballContainerView.subviews];
    item.elasticity = 1;
    [self.dynamicAnimator addBehavior:item];
}

#pragma mark - setter/getter
- (void)setIsLuxury:(BOOL)isLuxury
{
    _isLuxury = isLuxury;
    
    [self setupMakeCandyGiftView];
    [self setupMaterial];
}

- (void)setupMaterial
{
    if (self.isLuxury) {
        self.turntableImageView.image = [UIImage imageNamed:@"make_candy_open_rotation_luxury"];
        self.priceTipLabel.text = @"每制造1次消耗50个红音符";
    } else {
        self.turntableImageView.image = [UIImage imageNamed:@"make_candy_open_rotation_normal"];
        self.priceTipLabel.text = @"每制造1次消耗20个红音符";
    }
}

@end
