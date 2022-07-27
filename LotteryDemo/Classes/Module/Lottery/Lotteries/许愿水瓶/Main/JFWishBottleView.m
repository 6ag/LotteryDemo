//
//  JFWishBottleView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFWishBottleView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "JFWishBottleResultView.h"
#import "CALayer+FXAnimationEngine.h"

@interface JFWishBottleView () <FXAnimationDelegate>

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *waitBottleImageView;
@property (weak, nonatomic) IBOutlet UIImageView *openBottleImageView;

@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn1;
@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn2;

@property (weak, nonatomic) IBOutlet UIButton *openBtn1;
@property (weak, nonatomic) IBOutlet UIButton *openBtn2;
@property (weak, nonatomic) IBOutlet UIButton *openBtn3;
@property (weak, nonatomic) IBOutlet UILabel *openPriceLabel;

@property (nonatomic,assign) BOOL isRequesting;
@property (nonatomic, assign) BOOL isLuxury;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@property (nonatomic, strong) NSMutableArray<UIImage *> *waitFrameAnimList1;
@property (nonatomic, strong) NSMutableArray<UIImage *> *openFrameAnimList1;

@property (nonatomic, strong) NSMutableArray<UIImage *> *waitFrameAnimList2;
@property (nonatomic, strong) NSMutableArray<UIImage *> *openFrameAnimList2;

@end

@implementation JFWishBottleView

+ (void)show
{
    JFWishBottleView *view = [[NSBundle mainBundle] loadNibNamed:@"JFWishBottleView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    view.isLuxury = NO;
    
    view.alpha = 0;
    [UIView animateWithDuration:0.28 animations:^{
        view.alpha = 1;
    }];
}

- (void)closeDialog
{
    [UIView animateWithDuration:0.28 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }];
}

#pragma mark - 动画
/// 等待动画
- (void)setupWaitAnim
{
    FXKeyframeAnimation *animation = [FXKeyframeAnimation animation];
    animation.frames = [self.isLuxury ? self.waitFrameAnimList2 : self.waitFrameAnimList1 copy];
    animation.duration = 3;
    animation.repeats = 1000;
    [self.waitBottleImageView.layer fx_playAnimation:animation];
}

/// 抽奖动画
- (void)setupOpenAnim
{
    FXKeyframeAnimation *animation = [FXKeyframeAnimation animation];
    animation.frames = [self.isLuxury ? self.openFrameAnimList2 : self.openFrameAnimList1 copy];
    animation.duration = 3;
    animation.repeats = 1;
    [self.openBottleImageView.layer fx_playAnimation:animation];
}

- (void)startOpenAnimation
{
    self.waitBottleImageView.hidden = YES;
    self.openBottleImageView.hidden = NO;
    [self setupOpenAnim];
    
    // 当动画提前结束
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(openAnimDidStop) afterDelay:2.5];
}

- (void)openAnimDidStop
{
    self.waitBottleImageView.hidden = NO;
    self.openBottleImageView.hidden = YES;
    
    [self checkHadShowResult];
}

#pragma mark - UI
- (void)setupMaterial
{
    [self setupWaitAnim];
    
    if (self.isLuxury) {
        [self.openBtn1 setImage:[UIImage imageNamed:@"wish_bottle_open_count_1_luxury"] forState:UIControlStateNormal];
        [self.openBtn2 setImage:[UIImage imageNamed:@"wish_bottle_open_count_10_luxury"] forState:UIControlStateNormal];
        [self.openBtn3 setImage:[UIImage imageNamed:@"wish_bottle_open_count_100_luxury"] forState:UIControlStateNormal];
        
        self.titleImageView.image = [UIImage imageNamed:@"wish_bottle_open_title_luxury"];
    } else {
        [self.openBtn1 setImage:[UIImage imageNamed:@"wish_bottle_open_count_1_normal"] forState:UIControlStateNormal];
        [self.openBtn2 setImage:[UIImage imageNamed:@"wish_bottle_open_count_10_normal"] forState:UIControlStateNormal];
        [self.openBtn3 setImage:[UIImage imageNamed:@"wish_bottle_open_count_100_normal"] forState:UIControlStateNormal];
        
        self.titleImageView.image = [UIImage imageNamed:@"wish_bottle_open_title_normal"];
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
    self.isLuxury = NO;
}

- (IBAction)onClickLuxuryBtn:(id)sender
{
    self.isLuxury = YES;
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

/// 充值
- (IBAction)onClickRechargeBtn:(id)sender
{
    
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
- (void)setBtnUserInteractionEnabled:(BOOL)canTap
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
    [self startOpenAnimation];
    [self setBtnUserInteractionEnabled:NO];
    
    __weak typeof(self) weakSelf = self;
    [JFHttpRequestHelper wish:type success:^(id data) {
        weakSelf.isRequesting = NO;
        weakSelf.models = data;
    } failure:^(NSNumber *code, NSString *msg) {
        weakSelf.isRequesting = NO;
        [weakSelf setBtnUserInteractionEnabled:YES];
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
    [JFWishBottleResultView showWish:self.models isLuxury:self.isLuxury finished:^{
        [weakSelf setBtnUserInteractionEnabled:YES];
    }];
    self.models = nil;
}

#pragma mark - setter/getter
- (NSMutableArray<UIImage *> *)waitFrameAnimList1
{
    if (!_waitFrameAnimList1) {
        _waitFrameAnimList1 = [NSMutableArray array];
        for (int i = 1; i <= 100; i++) {
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"appptpz_%d", i] ofType:@"png"];
            [_waitFrameAnimList1 addObject:[[UIImage alloc] initWithContentsOfFile:imagePath]];
        }
    }
    return _waitFrameAnimList1;
}

- (NSMutableArray<UIImage *> *)openFrameAnimList1
{
    if (!_openFrameAnimList1) {
        _openFrameAnimList1 = [NSMutableArray array];
        for (int i = 1; i <= 100; i++) {
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"appptpzopen_%d", i] ofType:@"png"];
            [_openFrameAnimList1 addObject:[[UIImage alloc] initWithContentsOfFile:imagePath]];
        }
    }
    return _openFrameAnimList1;
}

- (NSMutableArray<UIImage *> *)waitFrameAnimList2
{
    if (!_waitFrameAnimList2) {
        _waitFrameAnimList2 = [NSMutableArray array];
        for (int i = 1; i <= 119; i++) {
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"appmhpz_%d", i] ofType:@"png"];
            [_waitFrameAnimList2 addObject:[[UIImage alloc] initWithContentsOfFile:imagePath]];
        }
    }
    return _waitFrameAnimList2;
}

- (NSMutableArray<UIImage *> *)openFrameAnimList2
{
    if (!_openFrameAnimList2) {
        _openFrameAnimList2 = [NSMutableArray array];
        for (int i = 1; i <= 111; i++) {
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"appmhpzopen_%d", i] ofType:@"png"];
            [_openFrameAnimList2 addObject:[[UIImage alloc] initWithContentsOfFile:imagePath]];
        }
    }
    return _openFrameAnimList2;
}

- (void)setIsLuxury:(BOOL)isLuxury
{
    _isLuxury = isLuxury;
    
    [self setupMaterial];
}

@end
