//
//  JFMoonTreasureView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFMoonTreasureView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "JFMoonTreasureResultView.h"

#define CONTENT_VIEW_HEIGHT (kScreenWidth/(375.0/500.0))

@interface JFMoonTreasureView ()

@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn1;
@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerX_lineView; // 自定义导航栏下划线图标中心约束

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIImageView *turntableBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *turntableImageView;
@property (weak, nonatomic) IBOutlet UIView *ballContainerView;
@property (strong, nonatomic) NSMutableArray<JFLotteryResultItem *> *giftArray;
@property (strong, nonatomic) NSMutableArray<JFLotteryResultItem *> *giftArray1;
@property (strong, nonatomic) NSMutableArray<JFLotteryResultItem *> *giftArray2;

@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;

@property (weak, nonatomic) IBOutlet UILabel *costLabel1;
@property (weak, nonatomic) IBOutlet UILabel *costLabel2;
@property (weak, nonatomic) IBOutlet UILabel *costLabel3;
@property (weak, nonatomic) IBOutlet UIButton *optionBtn1;
@property (weak, nonatomic) IBOutlet UIButton *optionBtn2;
@property (weak, nonatomic) IBOutlet UIButton *optionBtn3;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_contentView;

@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;

@property (nonatomic, assign) BOOL isAnimation;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, assign) BOOL isLuxury;

/// 当前选中下标，0、1、2
@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@end

@implementation JFMoonTreasureView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.isLuxury = NO;
    
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
    JFMoonTreasureView *view = [[NSBundle mainBundle] loadNibNamed:@"JFMoonTreasureView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];

    view.coverView.alpha = 0;
    view.bottom_contentView.constant = -CONTENT_VIEW_HEIGHT;
    [view layoutIfNeeded];
    [UIView animateWithDuration:0.28 animations:^{
        view.coverView.alpha = 1;
        view.bottom_contentView.constant = (iPhoneX ? 0 : -20);
        [view layoutIfNeeded];
    } completion:^(BOOL finished) {
        // 先从xib里加载一次结果单项视图，这样弹窗避免卡顿
        [UINib nibWithNibName:@"JFMoonTreasureResultItemView" bundle:nil];
    }];
    
    view.ballContainerView.layer.cornerRadius = view.ballContainerView.width * 0.5;
    view.ballContainerView.layer.masksToBounds = YES;
    view.dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:view.ballContainerView];
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
    
    self.navSwitchBtn1.titleLabel.font = JFFontPingFangSCRegular(16);
    self.navSwitchBtn2.titleLabel.font = JFFontPingFangSCRegular(14);
}

- (IBAction)onClickLuxuryBtn:(id)sender
{
    self.isLuxury = YES;
    
    self.navSwitchBtn1.selected = NO;
    self.navSwitchBtn2.selected = YES;
    
    [self setSelBarAnimation:1];
    
    self.navSwitchBtn1.titleLabel.font = JFFontPingFangSCRegular(14);
    self.navSwitchBtn2.titleLabel.font = JFFontPingFangSCRegular(16);
}

/// 自定义导航栏上的指示器滚动动画
- (void)setSelBarAnimation:(NSInteger)index
{
    [self.contentView layoutIfNeeded];
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.28 animations:^{
        if (index == 0) {
            weakSelf.centerX_lineView.constant = 0;
        } else if (index == 1) {
            weakSelf.centerX_lineView.constant = weakSelf.navSwitchBtn2.centerX - weakSelf.navSwitchBtn1.centerX;
        }
        [weakSelf.contentView layoutIfNeeded];
    }];
    
}

/// 关闭视图
- (IBAction)onClickCloseBtn:(id)sender
{
    [self closeDialog];
}

/// 礼物
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

/// 金币充值
- (IBAction)onClickCoinBtn:(id)sender
{
    
}

// 1次
- (IBAction)onClickOptionBtn1:(id)sender {
    [self switchOption:0];
}

// 10次
- (IBAction)onClickOptionBtn2:(id)sender {
    [self switchOption:1];
}

// 100次
- (IBAction)onClickOptionBtn3:(id)sender {
    [self switchOption:2];
}

// 开始抽奖
- (IBAction)onClickStartBtn:(id)sender {
    switch (self.selectedIndex) {
        case 0:
            [self openWishAction:1];
            break;
        case 1:
            [self openWishAction:2];
            break;
        case 2:
            [self openWishAction:5];
            break;
        default:
            break;
    }
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.isRequesting = NO;
            weakSelf.models = [data copy];

            // 弹出结果视图
            if (weakSelf.models) {
                [JFMoonTreasureResultView showWish:weakSelf.models];
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

/// 获取转盘礼物数据
- (void)getMoonTreasureGiftListData
{
    // 先加载内存中的礼物数据
    if (self.isLuxury) {
        if (self.giftArray2 && self.giftArray2.count > 0) {
            self.giftArray = [self.giftArray2 mutableCopy];
            [self setupMoonTreasureGiftView];
            return;
        }
    } else {
        if (self.giftArray1 && self.giftArray1.count > 0) {
            self.giftArray = [self.giftArray1 mutableCopy];
            [self setupMoonTreasureGiftView];
            return;
        }
    }
    
    self.giftArray = [NSMutableArray array];
    __weak typeof(self)weakSelf = self;
    
    [JFHttpRequestHelper getWishListWithSuccess:^(id  _Nonnull data) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.giftArray appendObjects:[data copy]];
            
            while (weakSelf.giftArray.count > 6) {
                [weakSelf.giftArray removeObjectAtIndex:0];
            }
            
            if (weakSelf.isLuxury) {
                weakSelf.giftArray2 = [weakSelf.giftArray mutableCopy];
            } else {
                weakSelf.giftArray1 = [weakSelf.giftArray mutableCopy];
            }
            
            [weakSelf setupMoonTreasureGiftView];
        });
    } failure:^(NSNumber * _Nonnull code, NSString * _Nonnull msg) {
        [weakSelf setupMoonTreasureGiftView];
        [MBProgressHUD showError:msg];
    }];
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

/// 配置转盘上的礼物视图
- (void)setupMoonTreasureGiftView
{
    [self layoutIfNeeded];
    [self.ballContainerView removeAllSubviews];
    
    CGFloat ballWidth = 55;
    CGFloat padding = 5;
    for (int i = 0; i < self.giftArray.count; i++) {
        if (i > 5) break;
        UIView *superView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ballWidth - padding * 2, ballWidth - padding * 2)];
        UIView *ballView = [[UIView alloc] initWithFrame:CGRectMake(-padding, -padding, ballWidth, ballWidth)];
        ballView.layer.cornerRadius = ballWidth * 0.5;
        ballView.layer.masksToBounds = YES;
        
        UIImageView *giftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, ballWidth - 20, ballWidth - 20)];
        giftImageView.layer.cornerRadius = giftImageView.frame.size.width * 0.5;
        giftImageView.image = [UIImage imageNamed:self.giftArray[i].picUrl];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        animation.fromValue = [NSNumber numberWithFloat:-2];
        animation.toValue = [NSNumber numberWithFloat:2];
        animation.duration = 0.5;
        animation.repeatCount = HUGE_VALF;
        animation.autoreverses = YES;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        [giftImageView.layer addAnimation:animation forKey:nil];
        
        NSString *ballImageName = @"";
        if (self.isLuxury) {
            ballImageName = [NSString stringWithFormat:@"turntable_open_gift_%d_luxury",i % 3 + 1];
        } else {
            ballImageName = [NSString stringWithFormat:@"turntable_open_gift_%d_normal",i % 3 + 1];
        }
        UIImageView *ballImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:ballImageName]];
        ballImageView.frame = CGRectMake(0, 0, ballWidth, ballWidth);
        
        NSString *kernerImageName = @"";
        if (self.isLuxury) {
            kernerImageName = [NSString stringWithFormat:@"turntable_open_gift_%d_kerner_luxury",i % 3 + 1];
        } else {
            kernerImageName = [NSString stringWithFormat:@"turntable_open_gift_%d_kerner_normal",i % 3 + 1];
        }
        UIImageView *kernerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kernerImageName]];
        kernerImageView.frame = CGRectMake(0, 0, ballWidth, ballWidth);
        
        [self.ballContainerView addSubview:superView];
        [superView addSubview:ballView];
        [ballView addSubview:kernerImageView];
        [ballView addSubview:giftImageView];
        [ballView addSubview:ballImageView];
        
        switch (i) {
            case 0:
                superView.center = CGPointMake(self.ballContainerView.width * 0.7, 100);
                break;
            case 1:
                superView.center = CGPointMake(self.ballContainerView.width * 0.5, 130);
                break;
            case 2:
                superView.center = CGPointMake(self.ballContainerView.width * 0.4, 70);
                break;
            case 3:
                superView.center = CGPointMake(self.ballContainerView.width * 0.1, 70);
                break;
            case 4:
                superView.center = CGPointMake(self.ballContainerView.width * 0.35, 100);
                break;
            case 5:
                superView.center = CGPointMake(self.ballContainerView.width * 0.9, 70);
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
    UICollisionBehavior *collision = [[UICollisionBehavior alloc]initWithItems:self.ballContainerView.subviews];
    collision.collisionMode = UICollisionBehaviorModeEverything;
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:self.ballContainerView.bounds];
    [collision addBoundaryWithIdentifier:@"collisionCircle" forPath:path];
    [self.dynamicAnimator addBehavior:collision];
    
    // 推力
    UIPushBehavior *push = [[UIPushBehavior alloc]initWithItems:self.ballContainerView.subviews mode:UIPushBehaviorModeInstantaneous];
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
    
    // 碰撞
    UICollisionBehavior *collision = [[UICollisionBehavior alloc]initWithItems:self.ballContainerView.subviews];
    collision.collisionMode = UICollisionBehaviorModeBoundaries;
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:self.ballContainerView.bounds];
    [collision addBoundaryWithIdentifier:@"collisionCircle" forPath:path];
    [self.dynamicAnimator addBehavior:collision];
    
    for (int i = 0; i < self.ballContainerView.subviews.count; i++) {
        // 推力
        UIPushBehavior *push = [[UIPushBehavior alloc]initWithItems:@[self.ballContainerView.subviews[i]] mode:UIPushBehaviorModeInstantaneous];
        [push setTargetOffsetFromCenter:UIOffsetMake(5 + 5 * i, 0) forItem:self.ballContainerView.subviews[0]];
        // x正右负左  y正下负上
        push.pushDirection = CGVectorMake(i % 2 == 0 ? 1 : -1, -1);
        push.angle = M_PI / self.ballContainerView.subviews.count * (arc4random() % 6);
        push.magnitude = 3;
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
    [self switchOption:self.selectedIndex];
    [self setupMaterial];
    [self getMoonTreasureGiftListData];
}

- (void)setupMaterial
{
    if (self.isLuxury) {
        self.turntableBgImageView.image = [UIImage imageNamed:@"turntable_open_container_luxury"];
        self.turntableImageView.image = [UIImage imageNamed:@"turntable_open_rotation_luxury"];
        
        self.costLabel1.text = @"200金币";
        self.costLabel2.text = @"2000金币";
        self.costLabel3.text = @"20000金币";
        [self.optionBtn1 setBackgroundImage:[UIImage imageNamed:@"turntable_open_normal_luxury"] forState:UIControlStateNormal];
        [self.optionBtn2 setBackgroundImage:[UIImage imageNamed:@"turntable_open_normal_luxury"] forState:UIControlStateNormal];
        [self.optionBtn3 setBackgroundImage:[UIImage imageNamed:@"turntable_open_normal_luxury"] forState:UIControlStateNormal];
        [self.optionBtn1 setBackgroundImage:[UIImage imageNamed:@"turntable_open_selected_luxury"] forState:UIControlStateSelected];
        [self.optionBtn2 setBackgroundImage:[UIImage imageNamed:@"turntable_open_selected_luxury"] forState:UIControlStateSelected];
        [self.optionBtn3 setBackgroundImage:[UIImage imageNamed:@"turntable_open_selected_luxury"] forState:UIControlStateSelected];
        [self.startBtn setImage:[UIImage imageNamed:@"turntable_open_start_luxury"] forState:UIControlStateNormal];
    } else {
        self.turntableBgImageView.image = [UIImage imageNamed:@"turntable_open_container_normal"];
        self.turntableImageView.image = [UIImage imageNamed:@"turntable_open_rotation_normal"];
        
        self.costLabel1.text = @"20金币";
        self.costLabel2.text = @"200金币";
        self.costLabel3.text = @"2000金币";
        [self.optionBtn1 setBackgroundImage:[UIImage imageNamed:@"turntable_open_normal_normal"] forState:UIControlStateNormal];
        [self.optionBtn2 setBackgroundImage:[UIImage imageNamed:@"turntable_open_normal_normal"] forState:UIControlStateNormal];
        [self.optionBtn3 setBackgroundImage:[UIImage imageNamed:@"turntable_open_normal_normal"] forState:UIControlStateNormal];
        [self.optionBtn1 setBackgroundImage:[UIImage imageNamed:@"turntable_open_selected_normal"] forState:UIControlStateSelected];
        [self.optionBtn2 setBackgroundImage:[UIImage imageNamed:@"turntable_open_selected_normal"] forState:UIControlStateSelected];
        [self.optionBtn3 setBackgroundImage:[UIImage imageNamed:@"turntable_open_selected_normal"] forState:UIControlStateSelected];
        [self.startBtn setImage:[UIImage imageNamed:@"turntable_open_start_normal"] forState:UIControlStateNormal];
    }
}

@end
