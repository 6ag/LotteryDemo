//
//  JFMagicPrayView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFMagicPrayView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "JFMagicPrayResultView.h"
#import "CALayer+FXAnimationEngine.h"

#define CONTENT_VIEW_HEIGHT (kScreenWidth/(375.0/533.0))

@interface JFMagicPrayView ()

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *animBtn;
@property (weak, nonatomic) IBOutlet UIView *emitterView;
@property (weak, nonatomic) IBOutlet UIView *animView;
@property (weak, nonatomic) IBOutlet UIButton *normalBtn;
@property (weak, nonatomic) IBOutlet UIButton *luxuryBtn;

@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet UIView *popupCoverView;
@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;

@property (weak, nonatomic) IBOutlet UIImageView *waitImageView;
@property (weak, nonatomic) IBOutlet UIImageView *openImageView;

@property (weak, nonatomic) IBOutlet UIButton *openBtn1;
@property (weak, nonatomic) IBOutlet UIButton *openBtn2;
@property (weak, nonatomic) IBOutlet UIButton *openBtn3;
@property (weak, nonatomic) IBOutlet UILabel *openLabel1;
@property (weak, nonatomic) IBOutlet UILabel *openLabel2;
@property (weak, nonatomic) IBOutlet UILabel *openLabel3;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_contentView;

@property (nonatomic,assign) BOOL isShowingOpenAnim;
@property (nonatomic,assign) BOOL isRequesting;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@property (nonatomic, assign) BOOL isLuxury;
@property (nonatomic, assign) NSInteger type;

@property (nonatomic, strong) NSMutableArray<UIImage *> *openFrameAnimList1;
@property (nonatomic, strong) NSMutableArray<UIImage *> *openFrameAnimList2;

@end

@implementation JFMagicPrayView

+ (void)show
{
    JFMagicPrayView *view = [[NSBundle mainBundle] loadNibNamed:@"JFMagicPrayView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    view.animBtn.selected = [[NSUserDefaults standardUserDefaults] boolForKey:@"TWISTED_EGG_ANIM_STATUS"];
    
    [view setupMaterial];
    [view setupWaitAnim];
    [view setupEmitter];
    
    view.coverView.alpha = 0;
    view.bottom_contentView.constant = -CONTENT_VIEW_HEIGHT;
    [view layoutIfNeeded];
    [UIView animateWithDuration:0.28 animations:^{
        view.coverView.alpha = 1;
        view.bottom_contentView.constant = (iPhoneX ? 0 : -20);
        [view layoutIfNeeded];
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
        [self clearAnim];
    }];
}

#pragma mark - UI
- (void)setupMaterial
{
    if (self.isLuxury) {
        self.normalBtn.selected = NO;
        self.luxuryBtn.selected = YES;
        
        self.openLabel1.text = @"20红音符";
        self.openLabel2.text = @"200红音符";
        self.openLabel3.text = @"2000红音符";
        
        self.waitImageView.image = [UIImage imageNamed:@"magic_pray_anim_luxury_10.png"];
    } else {
        self.normalBtn.selected = YES;
        self.luxuryBtn.selected = NO;
        
        self.openLabel1.text = @"10红音符";
        self.openLabel2.text = @"100红音符";
        self.openLabel3.text = @"1000红音符";
        
        self.waitImageView.image = [UIImage imageNamed:@"magic_pray_anim_normal_10.png"];
    }
}

#pragma mark - 动画
/// 等待动画
- (void)setupWaitAnim
{
    [self layoutIfNeeded];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    animation.toValue = @(self.animView.center.y + 20);
    animation.duration = 1.0f;
    animation.beginTime = 0.0f;
    animation.repeatCount = HUGE_VALF;
    animation.autoreverses = YES;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    
    [self.animView.layer addAnimation:animation forKey:nil];
}

/// 抽奖动画
- (void)setupOpenAnim
{
    FXKeyframeAnimation *animation = [FXKeyframeAnimation animation];
    if (self.isLuxury) {
        animation.frames = [self.openFrameAnimList2 copy];
    } else {
        animation.frames = [self.openFrameAnimList1 copy];
    }
    animation.duration = 3;
    animation.repeats = 1;
    [self.openImageView.layer fx_playAnimation:animation];
}

- (void)startOpenAnimation
{
    self.waitImageView.hidden = YES;
    self.openImageView.hidden = NO;
    [self setupOpenAnim];
    
    // 当动画提前结束
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(openAnimDidStop) afterDelay:2.5];
}

/// 动画结束
- (void)openAnimDidStop
{
    self.waitImageView.hidden = NO;
    self.openImageView.hidden = YES;
    
    [self checkHadShowResult];
}

/// 清理动画
- (void)clearAnim
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.animView.layer removeAllAnimations];
    [self stopEmitter];
}

#pragma mark - 粒子特效
// 添加粒子发射器
- (void)setupEmitter
{
    CAEmitterLayer *emitter = [[CAEmitterLayer alloc]init];
    // 发射位置
    emitter.emitterPosition = CGPointMake(self.emitterView.center.x, self.emitterView.center.y - 55);
    // 决定粒子形状的深度
    emitter.preservesDepth = YES;
    // 发射源的形状
    emitter.emitterShape = kCAEmitterLayerCircle;
    // 发射模式
    emitter.emitterMode = kCAEmitterLayerPoints;
    
    NSMutableArray *cellArr = [NSMutableArray array];
    for (int i = 0 ; i < 30; i++) {
        CAEmitterCell *cell = [[CAEmitterCell alloc] init];
        
        // 设置粒子生命周期
        cell.lifetime = 3.5;
        // 生命周期范围
        cell.lifetimeRange = 1.5;
        
        // 设置粒子速度
        cell.velocity = 40;
        // 设置粒子速度范围
        cell.velocityRange = 20;
        // 设置粒子参数的速度乘数因子
        cell.birthRate = 2;
        
        // 缩放比例
        cell.scale = 0.7;
        // 缩放比例范围
        cell.scaleRange = 0.3;
        
        // 子旋转角度
        cell.spin = M_PI_2;
        // 子旋转角度范围
        cell.spinRange = M_PI_2 / 2;
        
        // x-y 平面的发射方向
        cell.emissionLongitude = 2 * M_PI / 30 * i;
        // 周围发射角度
        cell.emissionRange = M_PI_2 / 8;
        
        cell.contents = (__bridge id _Nullable)([UIImage imageNamed:@"magic_pray_open_effect"].CGImage);
        [cellArr addObject:cell];
    }
    
    emitter.emitterCells = cellArr;
    [self.emitterView.layer addSublayer:emitter];
}

// 移除粒子发射器
- (void)stopEmitter
{
    for (CALayer *emitter in self.emitterView.layer.sublayers) {
        if ([emitter isKindOfClass:[CAEmitterLayer class]]) {
            [emitter removeFromSuperlayer];
        }
    }
}

#pragma mark - Event
/// 关闭视图
- (IBAction)onClickCloseBtn:(id)sender
{
    [self closeDialog];
}

- (IBAction)onClickNormalBtn:(id)sender
{
    if (self.isLuxury) {
        self.isLuxury = NO;
    }
}

- (IBAction)onClickLuxuryBtn:(id)sender
{
    if (!self.isLuxury) {
        self.isLuxury = YES;
    }
}

/// 充值
- (IBAction)onClickRechargeBtn:(id)sender
{
    
}

- (IBAction)onClickAnimBtn:(id)sender
{
    self.animBtn.selected = !self.animBtn.selected;
    [[NSUserDefaults standardUserDefaults] setBool:self.animBtn.selected forKey:@"TWISTED_EGG_ANIM_STATUS"];
}

- (IBAction)onClickMoreBtn:(id)sender
{
    self.popupView.hidden = NO;
    self.popupCoverView.hidden = NO;
}

- (IBAction)onClickPopupCoverView:(id)sender
{
    self.popupView.hidden = YES;
    self.popupCoverView.hidden = YES;
}

/// 礼物
- (IBAction)onClickGiftBtn:(id)sender
{
    [self onClickPopupCoverView:nil];
}

/// 记录
- (IBAction)onClickRecordBtn:(id)sender
{
    [self onClickPopupCoverView:nil];
}

/// 排行
- (IBAction)onClickRankBtn:(id)sender
{
    [self onClickPopupCoverView:nil];
}

/// 规则
- (IBAction)onClickRuleBtn:(id)sender
{
    [self onClickPopupCoverView:nil];
}

- (IBAction)onClickOpenBtn1:(id)sender
{
    [self openWishAction:1];
}

- (IBAction)onClickOpenBtn2:(id)sender
{
    [self openWishAction:2];
}

- (IBAction)onClickOpenBtn3:(id)sender
{
    [self openWishAction:5];
}

/// 切换喂食按钮交互
/// @param canTap 是否可以点击
- (void)setWishBtnUserinterface:(BOOL)canTap
{
    self.openBtn1.userInteractionEnabled = canTap;
    self.openBtn2.userInteractionEnabled = canTap;
    self.openBtn3.userInteractionEnabled = canTap;
}

#pragma mark - Network
/// 许愿动作
/// @param type 1-1次 2-10次 5-100次
- (void)openWishAction:(NSInteger)type
{
    if (self.isRequesting) {
        return;
    }
    
    self.isRequesting = YES;
    if (!self.animBtn.selected) {
        [self startOpenAnimation];
    }
    [self setWishBtnUserinterface:NO];
    
    __weak typeof(self) weakSelf = self;
    [JFHttpRequestHelper wish:type success:^(id data) {
        
        weakSelf.isRequesting = NO;
        weakSelf.models = data;
        weakSelf.models.firstObject.againType = type;
        
        if (weakSelf.animBtn.selected) {
            [weakSelf checkHadShowResult];
        }
        
    } failure:^(NSNumber *code, NSString *msg) {
        weakSelf.isRequesting = NO;
        [weakSelf setWishBtnUserinterface:YES];
        [MBProgressHUD showError:msg];
    }];
}

/// 显示开箱子结果弹窗视图
- (void)checkHadShowResult
{
    if (self.isRequesting || self.models == nil) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [JFMagicPrayResultView showWish:self.models againBlock:^(NSInteger type) {
        [weakSelf openWishAction:type];
    }];
    self.models = nil;
    [self setWishBtnUserinterface:YES];
}

#pragma mark - setter/getter
- (void)setIsLuxury:(BOOL)isLuxury
{
    _isLuxury = isLuxury;
    
    [self setupMaterial];
}

- (NSMutableArray<UIImage *> *)openFrameAnimList1
{
    if (!_openFrameAnimList1) {
        _openFrameAnimList1 = [NSMutableArray array];
        for (int i = 10; i <= 40; i++) {
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"magic_pray_anim_normal_%d", i] ofType:@"png"];
            [_openFrameAnimList1 addObject:[[UIImage alloc] initWithContentsOfFile:imagePath]];
        }
    }
    return _openFrameAnimList1;
}

- (NSMutableArray<UIImage *> *)openFrameAnimList2
{
    if (!_openFrameAnimList2) {
        _openFrameAnimList2 = [NSMutableArray array];
        for (int i = 10; i <= 40; i++) {
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"magic_pray_anim_luxury_%d", i] ofType:@"png"];
            [_openFrameAnimList2 addObject:[[UIImage alloc] initWithContentsOfFile:imagePath]];
        }
    }
    return _openFrameAnimList2;
}

@end
