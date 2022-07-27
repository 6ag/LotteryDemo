//
//  JFBindBoxView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFBindBoxView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "JFBindBoxResultItemView.h"
#import "BBMaskVideoPlayerLayer.h"
#import <AudioToolbox/AudioToolbox.h>
#import "JFBindBoxResultItemView.h"

#define CONTENT_VIEW_HEIGHT (kScreenWidth/(360.f/460.f))

@interface JFBindBoxView () <BBMaskVideoPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *countPopupView;

@property (weak, nonatomic) IBOutlet UIView *bgPlayerView;
@property (weak, nonatomic) IBOutlet UIView *openPlayerView;
@property (weak, nonatomic) IBOutlet UIView *scrollPlayerView;
@property (weak, nonatomic) IBOutlet UIView *light1PlayerView;
@property (weak, nonatomic) IBOutlet UIView *light2PlayerView;

@property (nonatomic, strong) BBMaskVideoPlayerLayer *bgPlayerLayer;
@property (nonatomic, strong) BBMaskVideoPlayerLayer *openPlayerLayer;
@property (nonatomic, strong) BBMaskVideoPlayerLayer *scrollPlayerLayer;
@property (nonatomic, strong) BBMaskVideoPlayerLayer *light1PlayerLayer;
@property (nonatomic, strong) BBMaskVideoPlayerLayer *light2PlayerLayer;

@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;

@property (weak, nonatomic) IBOutlet UIButton *openBtn1;
@property (weak, nonatomic) IBOutlet UIButton *openBtn2;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_contentView;

@property (nonatomic,assign) BOOL isShowingOpenAnim;
@property (nonatomic,assign) BOOL isRequesting;
@property (nonatomic,assign) BOOL isAutoOpen;
@property (nonatomic,assign) NSInteger type;
@property (nonatomic,strong) NSTimer *openTmer;

@property (nonatomic, strong) NSURL *openUrl;
@property (nonatomic, strong) NSURL *scrollUrl;
@property (nonatomic, strong) NSURL *bgUrl;
@property (nonatomic, strong) NSURL *light1Url;
@property (nonatomic, strong) NSURL *light2Url;

@property (nonatomic, strong) UINib *itemViewNib;

@end

@implementation JFBindBoxView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.openUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bind_box_open" ofType:@"mp4"]];
    self.scrollUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bind_box_scroll" ofType:@"mp4"]];
    self.bgUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bind_box_bg" ofType:@"mp4"]];
    
    self.light1Url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bind_box_light_1" ofType:@"mp4"]];
    self.light2Url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bind_box_light_2" ofType:@"mp4"]];
}

+ (void)show
{
    JFBindBoxView *view = [[NSBundle mainBundle] loadNibNamed:@"JFBindBoxView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    [view addNotification];
    [view setupScrollAnim];
    [view setupBgAnim];
    [view setupOpenAnimWithIsInit:YES];
    [view setupLight1Anim];
    [view setupLight2Anim];
    
    view.coverView.alpha = 0;
    view.bottom_contentView.constant = -CONTENT_VIEW_HEIGHT;
    [view layoutIfNeeded];
    [UIView animateWithDuration:0.28 animations:^{
        view.coverView.alpha = 1;
        view.bottom_contentView.constant = (iPhoneX ? 0 : -20);
        [view layoutIfNeeded];
    } completion:^(BOOL finished) {
        view.itemViewNib = [UINib nibWithNibName:@"JFBindBoxResultItemView" bundle:nil];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopAutoOpen];
}

- (void)addNotification
{
    //后台进前台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];

    //进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
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

- (void)didBecomeActive
{
    [self.bgPlayerLayer resume];
}

- (void)didEnterBackground
{
    [self.bgPlayerLayer pause];
}

#pragma mark - 动画
/// 配置滚动动画
- (void)setupScrollAnim
{
    if (!self.scrollPlayerLayer.superlayer) {
        [self layoutIfNeeded];
        self.scrollPlayerLayer = [BBMaskVideoPlayerLayer layer];
        self.scrollPlayerLayer.frame = self.scrollPlayerView.bounds;
        [self.scrollPlayerView.layer addSublayer:self.scrollPlayerLayer];
        self.scrollPlayerLayer.loop = 0;
        self.scrollPlayerLayer.type = 2;
    }
    [self.scrollPlayerLayer playVideoURL:self.scrollUrl isInit:NO];
}

/// 配置背景动画
- (void)setupBgAnim
{
    if (!self.bgPlayerLayer.superlayer) {
        [self layoutIfNeeded];
        self.bgPlayerLayer = [BBMaskVideoPlayerLayer layer];
        self.bgPlayerLayer.frame = self.bgPlayerView.bounds;
        [self.bgPlayerView.layer addSublayer:self.bgPlayerLayer];
        self.bgPlayerLayer.loop = 0;
        self.bgPlayerLayer.type = 1;
    }

    [self.bgPlayerLayer playVideoURL:self.bgUrl isInit:NO];
}

/// 配置打开动画
- (void)setupOpenAnimWithIsInit:(BOOL)isInit
{
    if (!self.openPlayerLayer.superlayer) {
        [self layoutIfNeeded];
        self.openPlayerLayer = [BBMaskVideoPlayerLayer layer];
        self.openPlayerLayer.playDelegate = self;
        self.openPlayerLayer.frame = self.openPlayerView.bounds;
        [self.openPlayerView.layer addSublayer:self.openPlayerLayer];
        self.openPlayerLayer.loop = -1;
        self.openPlayerLayer.type = 2;
    }
    
    [self.openPlayerLayer playVideoURL:self.openUrl isInit:isInit];
}

/// 配置背景动画
- (void)setupLight1Anim
{
    if (!self.light1PlayerLayer.superlayer) {
        [self layoutIfNeeded];
        self.light1PlayerLayer = [BBMaskVideoPlayerLayer layer];
        self.light1PlayerLayer.frame = self.light1PlayerView.bounds;
        [self.light1PlayerView.layer addSublayer:self.light1PlayerLayer];
        self.light1PlayerLayer.loop = 0;
        self.light1PlayerLayer.type = 1;
    }

    [self.light1PlayerLayer playVideoURL:self.light1Url isInit:NO];
}

/// 配置背景动画
- (void)setupLight2Anim
{
    if (!self.light2PlayerLayer.superlayer) {
        [self layoutIfNeeded];
        self.light2PlayerLayer = [BBMaskVideoPlayerLayer layer];
        self.light2PlayerLayer.frame = self.light2PlayerView.bounds;
        [self.light2PlayerView.layer addSublayer:self.light2PlayerLayer];
        self.light2PlayerLayer.loop = 0;
        self.light2PlayerLayer.type = 1;
    }

    [self.light2PlayerLayer playVideoURL:self.light2Url isInit:NO];
}

/// 清理动画
- (void)clearAnim
{
    [self.bgPlayerLayer clear];
    [self.openPlayerLayer clear];
    [self.scrollPlayerLayer clear];
}

/// 开始动画
- (void)startOpenAnimation
{
    if (!self.isShowingOpenAnim) {
        self.isShowingOpenAnim = YES;
        [self setupOpenAnimWithIsInit:NO];
    }
}

#pragma mark - BBMaskVideoPlayerDelegate
- (void)maskVideoDidPlayOnce:(BBMaskVideoPlayerLayer *)playerLayer
{
    self.isShowingOpenAnim = NO;
}

#pragma mark - Event
/// 关闭视图
- (IBAction)onClickCloseBtn:(id)sender
{
    [self closeDialog];
    [self stopAutoOpen];
}

/// 充值
- (IBAction)onClickRechargeBtn:(id)sender
{
    
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

- (IBAction)onClickOpenBtn1:(id)sender
{
    self.type = 1;
    [self openWishAction];
}

- (IBAction)onClickOpenBtn2:(id)sender
{
    if (!self.isAutoOpen) {
        self.countPopupView.hidden = NO;
    } else {
        [self.openBtn2 setBackgroundImage:[UIImage imageNamed:@"bind_box_open_count_auto"] forState:UIControlStateNormal];
        [self stopAutoOpen];
    }
}

- (IBAction)onTapPopupView:(id)sender
{
    self.countPopupView.hidden = YES;
}

- (IBAction)OnClickCount10:(id)sender
{
    self.countPopupView.hidden = YES;
    [self.openBtn2 setBackgroundImage:[UIImage imageNamed:@"bind_box_open_count_auto_10"] forState:UIControlStateNormal];
    self.type = 2;
    [self startAutoOpen];
}

- (IBAction)OnClickCount20:(id)sender
{
    self.countPopupView.hidden = YES;
    [self.openBtn2 setBackgroundImage:[UIImage imageNamed:@"bind_box_open_count_auto_20"] forState:UIControlStateNormal];
    self.type = 3;
    [self startAutoOpen];
}

- (IBAction)OnClickCount30:(id)sender
{
    self.countPopupView.hidden = YES;
    [self.openBtn2 setBackgroundImage:[UIImage imageNamed:@"bind_box_open_count_auto_30"] forState:UIControlStateNormal];
    self.type = 4;
    [self startAutoOpen];
}

- (void)startAutoOpen
{
    self.isAutoOpen = YES;
    self.openBtn1.enabled = !self.isAutoOpen;
    self.openTmer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(openWishAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.openTmer forMode:NSRunLoopCommonModes];
    
    // 立即执行一次
    [self.openTmer fire];
}

- (void)stopAutoOpen
{
    self.isAutoOpen = NO;
    if (self.openTmer) {
        [self.openTmer invalidate];
        self.openTmer = nil;
    }
    
    self.openBtn1.enabled = [self.goldBalanceLabel.text doubleValue] >= 100;
}

#pragma mark - Network
- (void)openWishAction
{
    self.isRequesting = YES;
    [self startOpenAnimation];
    
    [JFHttpRequestHelper wish:self.type success:^(id data) {
        self.isRequesting = NO;
        [self checkHadShowResult:data];
    } failure:^(NSNumber *code, NSString *msg) {
        self.isRequesting = NO;
        [MBProgressHUD showError:msg];
        
        // 抽奖失败后，校验是否是自动抽奖。是则停止自动抽奖
        if (self.isAutoOpen) {
            [self.openBtn2 setBackgroundImage:[UIImage imageNamed:@"bind_box_open_count_auto"] forState:UIControlStateNormal];
            [self stopAutoOpen];
        }
    }];
}

/// 显示开箱子结果弹窗视图
- (void)checkHadShowResult:(NSArray<JFLotteryResultItem *> *)models
{
    if (!self.itemViewNib) {
        return;
    }
    
    NSInteger totalPrice = 0;
    BOOL needShake = NO;
    for (JFLotteryResultItem *item in models) {
        if (item.goldPrice >= 5000) {
            needShake = YES;
        }
        totalPrice += item.goldPrice * item.num;
        
        JFBindBoxResultItemView *itemView = [self.itemViewNib instantiateWithOwner:nil options:nil].firstObject;
        itemView.model = item;
        
        CGRect openPlayerViewRect = [self.openPlayerView convertRect:self.openPlayerView.bounds toView:self];
        itemView.frame = CGRectMake(0, 0, 50, 50);
        itemView.center = CGPointMake(SCREEN_WIDTH * 0.5, CGRectGetMaxY(openPlayerViewRect));
        [self addSubview:itemView];
        
        [itemView startAnimation];
    }
    if (needShake) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

@end
