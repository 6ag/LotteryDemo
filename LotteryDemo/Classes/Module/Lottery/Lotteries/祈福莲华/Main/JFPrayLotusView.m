//
//  JFPrayLotusView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFPrayLotusView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "JFPrayLotusResultView.h"
#import "SVGAVideoEntity.h"
#import "SLMaskVideoPlayerLayer.h"

#define CONTENT_VIEW_HEIGHT (kScreenWidth/(414.0/540.0))

@interface JFPrayLotusView () <maskVideoPlayDelegate>

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *normalBtn;
@property (weak, nonatomic) IBOutlet UIButton *luxuryBtn;

@property (weak, nonatomic) IBOutlet UIView *waitPlayerView;
@property (weak, nonatomic) IBOutlet UIView *openPlayerView;
@property (nonatomic, strong) SLMaskVideoPlayerLayer *waitPlayerLayer;
@property (nonatomic, strong) SLMaskVideoPlayerLayer *openPlayerLayer;

@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;

@property (weak, nonatomic) IBOutlet UIButton *openBtn1;
@property (weak, nonatomic) IBOutlet UIButton *openBtn2;
@property (weak, nonatomic) IBOutlet UIButton *openBtn3;
@property (weak, nonatomic) IBOutlet UILabel *openLabel1;
@property (weak, nonatomic) IBOutlet UILabel *openLabel2;
@property (weak, nonatomic) IBOutlet UILabel *openLabel3;

@property (weak, nonatomic) IBOutlet UIView *funcLineView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_contentView;

@property (nonatomic,assign) BOOL isShowingOpenAnim;
@property (nonatomic,assign) BOOL isRequesting;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@property (nonatomic, assign) BOOL isLuxury;

@property (nonatomic, strong) NSURL *waitUrl;
@property (nonatomic, strong) NSURL *openUrl;

@property (nonatomic, strong) NSMutableArray<NSURL *> *urlList;

@end

@implementation JFPrayLotusView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.urlList = [NSMutableArray array];
    [self.urlList addObject:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"pray_lotus_dream_wait" ofType:@"mp4"]]];
    [self.urlList addObject:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"pray_lotus_dream_open" ofType:@"mp4"]]];
    [self.urlList addObject:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"pray_lotus_normal_wait" ofType:@"mp4"]]];
    [self.urlList addObject:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"pray_lotus_normal_open" ofType:@"mp4"]]];
}

+ (void)show
{
    JFPrayLotusView *view = [[NSBundle mainBundle] loadNibNamed:@"JFPrayLotusView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    [view addNotification];
    [view setupMaterial];
    [view setupFuncLineViewAnim];

    view.coverView.alpha = 0;
    view.bottom_contentView.constant = -CONTENT_VIEW_HEIGHT;
    [view layoutIfNeeded];
    [UIView animateWithDuration:0.28 animations:^{
        view.coverView.alpha = 1;
        view.bottom_contentView.constant = (iPhoneX ? 0 : -20);
        [view layoutIfNeeded];
    }];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [self.waitPlayerLayer resume];
}

- (void)didEnterBackground
{
    [self.waitPlayerLayer pause];
}

#pragma mark - UI
- (void)setupMaterial
{
    if (self.urlList.count < 4) {
        return;
    }
    
    if (self.isLuxury) {
        self.normalBtn.selected = NO;
        self.luxuryBtn.selected = YES;

        self.openLabel1.text = @"(需20金币)";
        self.openLabel2.text = @"(需200金币)";
        self.openLabel3.text = @"(需2000金币)";
        
        self.waitUrl = self.urlList[0];
        self.openUrl = self.urlList[1];
    } else {
        self.normalBtn.selected = YES;
        self.luxuryBtn.selected = NO;

        self.openLabel1.text = @"(需5金币)";
        self.openLabel2.text = @"(需50金币)";
        self.openLabel3.text = @"(需500金币)";
        
        self.waitUrl = self.urlList[2];
        self.openUrl = self.urlList[3];
    }
    
    [self setupWaitAnim];
}

#pragma mark - 动画
/// 配置功能线视图的摇摆动画
- (void)setupFuncLineViewAnim
{
    self.funcLineView.layer.anchorPoint = CGPointMake(0.5, 0);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:-5 / 180.0 * M_PI];
    animation.toValue = [NSNumber numberWithFloat:5 / 180.0 * M_PI];
    animation.duration = 3;
    animation.repeatCount = HUGE_VALF;
    animation.autoreverses = YES;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    
    [self.funcLineView.layer addAnimation:animation forKey:nil];
}

/// 配置等待动画
- (void)setupWaitAnim
{
    if (!self.waitPlayerLayer.superlayer) {
        [self layoutIfNeeded];
        self.waitPlayerLayer = [SLMaskVideoPlayerLayer layer];
        self.waitPlayerLayer.frame = self.waitPlayerView.bounds;
        [self.waitPlayerView.layer addSublayer:self.waitPlayerLayer];
        self.waitPlayerLayer.loop = 0;
    }
    
    [self.waitPlayerLayer playVideoURL:self.waitUrl];
}

/// 配置打开动画
- (void)setupOpenAnim
{
    if (!self.openPlayerLayer.superlayer) {
        [self layoutIfNeeded];
        self.openPlayerLayer = [SLMaskVideoPlayerLayer layer];
        self.openPlayerLayer.playDelegate = self;
        self.openPlayerLayer.frame = self.openPlayerView.bounds;
        [self.openPlayerView.layer addSublayer:self.openPlayerLayer];
    }
    
    [self.openPlayerLayer playVideoURL:self.openUrl];
}

/// 清理动画
- (void)clearAnim
{
    [self.waitPlayerLayer clear];
    [self.openPlayerLayer clear];
    [self.funcLineView.layer removeAllAnimations];
}

/// 开始动画
- (void)startOpenAnimation
{
    self.isShowingOpenAnim = YES;
    self.waitPlayerView.hidden = YES;
    self.openPlayerView.hidden = NO;
    
    // 播放打开动画
    [self setupOpenAnim];
}

/// 动画结束
- (void)maskVideoDidPlayFinish:(SLMaskVideoPlayerLayer *)playerLayer
{
    if (self.isShowingOpenAnim) {
        self.isShowingOpenAnim = NO;
        self.waitPlayerView.hidden = NO;
        self.openPlayerView.hidden = YES;
        
        // 检测是否能弹窗
        [self checkHadShowResult];
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
    [self startOpenAnimation];
    [self setWishBtnUserinterface:NO];
    
    __weak typeof(self) weakSelf = self;
    [JFHttpRequestHelper wish:type success:^(id data) {
        
        weakSelf.isRequesting = NO;
        weakSelf.models = [data copy];
        
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
    
    // 弹出结果视图
    @weakify(self);
    [JFPrayLotusResultView showWish:self.models dismiss:^{
        @strongify(self);
        if (self.isShowingOpenAnim) {
            self.isShowingOpenAnim = NO;
            [self.openPlayerLayer clear];
            self.waitPlayerView.hidden = NO;
            self.openPlayerView.hidden = YES;
        }
    }];
    [self setWishBtnUserinterface:YES];
    self.models = nil;
}

#pragma mark - setter/getter
- (void)setIsLuxury:(BOOL)isLuxury
{
    _isLuxury = isLuxury;
    
    [self setupMaterial];
}

@end
