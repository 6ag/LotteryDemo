//
//  JFSummonBeastView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFSummonBeastView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "JFSummonBeastResultView.h"
#import "CALayer+FXAnimationEngine.h"

#define CONTENT_VIEW_HEIGHT (kScreenWidth/(375.0/560.0))

@interface JFSummonBeastView ()

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIImageView *waitWeaponImageView;
@property (weak, nonatomic) IBOutlet UIImageView *openWeaponImageView;

@property (weak, nonatomic) IBOutlet UIButton *animBtn;
@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *openBtn1;
@property (weak, nonatomic) IBOutlet UIButton *openBtn2;
@property (weak, nonatomic) IBOutlet UIButton *openBtn3;

@property (weak, nonatomic) IBOutlet UIImageView *rechargeBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_contentView;

@property (nonatomic,assign) BOOL isRequesting;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@property (nonatomic, strong) NSMutableArray<UIImage *> *waitFrameAnimList;
@property (nonatomic, strong) NSMutableArray<UIImage *> *openFrameAnimList;

@end

@implementation JFSummonBeastView

+ (void)show
{
    JFSummonBeastView *view = [[NSBundle mainBundle] loadNibNamed:@"JFSummonBeastView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];

    [view setupWaitAnim];
    view.animBtn.selected = [[NSUserDefaults standardUserDefaults] boolForKey:@"TURNTABLE_ANIM_STATUS"];

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
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }];
}

#pragma mark - 动画
/// 等待动画
- (void)setupWaitAnim
{
    FXKeyframeAnimation *animation = [FXKeyframeAnimation animation];
    animation.frames = [self.waitFrameAnimList copy];
    animation.duration = 1;
    animation.repeats = 1000;
    [self.waitWeaponImageView.layer fx_playAnimation:animation];
}

/// 抽奖动画
- (void)setupOpenAnim
{
    FXKeyframeAnimation *animation = [FXKeyframeAnimation animation];
    animation.frames = [self.openFrameAnimList copy];
    animation.duration = 1.5;
    animation.repeats = 1;
    [self.openWeaponImageView.layer fx_playAnimation:animation];
}

- (void)startOpenAnimation
{
    self.waitWeaponImageView.hidden = YES;
    self.openWeaponImageView.hidden = NO;
    [self setupOpenAnim];
    
    // 当动画提前结束
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(openAnimDidStop) afterDelay:1.5];
}

- (void)openAnimDidStop
{
    self.waitWeaponImageView.hidden = NO;
    self.openWeaponImageView.hidden = YES;
    
    [self checkHadShowResult];
}

#pragma mark - Event
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

/// 红音符充值
- (IBAction)onClickCoinBtn:(id)sender
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

- (void)setWishBtnUserinterface:(BOOL)canTap
{
    self.openBtn1.userInteractionEnabled = canTap;
    self.openBtn2.userInteractionEnabled = canTap;
    self.openBtn3.userInteractionEnabled = canTap;
}

- (IBAction)onClickAnimBtn:(id)sender
{
    self.animBtn.selected = !self.animBtn.selected;
    [[NSUserDefaults standardUserDefaults] setBool:self.animBtn.selected forKey:@"TURNTABLE_ANIM_STATUS"];
}

#pragma mark - Network
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
        
        if (weakSelf.animBtn.selected) {
            [weakSelf checkHadShowResult];
        } else if (weakSelf.openWeaponImageView.hidden) {
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
    
    [JFSummonBeastResultView showWish:self.models];
    [self setWishBtnUserinterface:YES];
    self.models = nil;
}

#pragma mark - setter/getter
- (NSMutableArray<UIImage *> *)waitFrameAnimList
{
    if (!_waitFrameAnimList) {
        _waitFrameAnimList = [NSMutableArray array];
        for (int i = 0; i <= 24; i++) {
            if (i == 9) {
                continue;
            }
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"summon_beast_weapon_%03d", i] ofType:@"png"];
            [_waitFrameAnimList addObject:[[UIImage alloc] initWithContentsOfFile:imagePath]];
        }
    }
    return _waitFrameAnimList;
}

- (NSMutableArray<UIImage *> *)openFrameAnimList
{
    if (!_openFrameAnimList) {
        _openFrameAnimList = [NSMutableArray array];
        for (int i = 25; i <= 44; i++) {
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"summon_beast_weapon_%03d", i] ofType:@"png"];
            [_openFrameAnimList addObject:[[UIImage alloc] initWithContentsOfFile:imagePath]];
        }
    }
    return _openFrameAnimList;
}

@end
