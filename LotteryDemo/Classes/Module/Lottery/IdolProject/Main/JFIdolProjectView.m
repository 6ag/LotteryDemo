//
//  JFIdolProjectView.m
//  VoiceChat
//
//  Created by feng on 2020/9/6.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFIdolProjectView.h"
#import "SVGAParser.h"
#import "SVGAImageView.h"
#import "SVGAVideoEntity.h"
#import "JFIdolProjectResultView.h"
#import "JFHttpRequestHelper.h"

@interface JFIdolProjectView () <SVGAPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet SVGAImageView *svgaBoxView;
@property (weak, nonatomic) IBOutlet SVGAImageView *svgaOpenBoxView;

@property (weak, nonatomic) IBOutlet UIButton *openBtn1;
@property (weak, nonatomic) IBOutlet UIButton *openBtn2;
@property (weak, nonatomic) IBOutlet UIButton *openBtn3;

@property (weak, nonatomic) IBOutlet UIButton *giftAnimationBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_contentView;

@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;

@property (nonatomic,assign) BOOL isShowingSvga;
@property (nonatomic,assign) BOOL isRequesting;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;
@property (assign,nonatomic) NSInteger againType;

@end

@implementation JFIdolProjectView

+ (void)show
{
    JFIdolProjectView *view = [[NSBundle mainBundle] loadNibNamed:@"JFIdolProjectView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    view.giftAnimationBtn.selected = ![[NSUserDefaults standardUserDefaults] boolForKey:@"CloseIdolBoxAnimation"];
    
    [view addNotification];
    
    view.svgaOpenBoxView.delegate = view;
    
    view.bgView.alpha = 0;
    view.bottom_contentView.constant = -(iPhoneX ? 380 : 360);
    [view layoutIfNeeded];
    [UIView animateWithDuration:0.28 animations:^{
        view.bgView.alpha = 1;
        view.bottom_contentView.constant = (iPhoneX ? 0 : -20);
        [view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onClickCloseBtn:) name:@"CloseRoomDialogView" object:nil];
}

#pragma mark - Event
/// 关闭视图
- (IBAction)onClickCloseBtn:(id)sender
{
    [UIView animateWithDuration:0.28 animations:^{
        self.bgView.alpha = 0;
        self.bottom_contentView.constant = -(iPhoneX ? 380 : 360);
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

/// 开启1次
- (IBAction)onClickOpenBtn1:(id)sender
{
    [self openWishAction:1];
}

/// 开启10次
- (IBAction)onClickOpenBtn2:(id)sender
{
    [self openWishAction:2];
}

/// 开启20次
- (IBAction)onClickOpenBtn3:(id)sender
{
    [self openWishAction:3];
}

/// 助力能量
- (IBAction)onTapEnergyView:(id)sender {
    [self onClickCloseBtn:nil];
}

/// 排行
- (IBAction)onClickRankBtn:(id)sender
{
    
}

/// 礼品
- (IBAction)onClickGiftBtn:(id)sender
{
    
}

/// 记录
- (IBAction)onClickRecordBtn:(id)sender
{
    
}

/// 礼物动画开关
- (IBAction)onClickAnimationSwitchBtn:(id)sender
{
    self.giftAnimationBtn.selected = !self.giftAnimationBtn.selected;
    [[NSUserDefaults standardUserDefaults] setBool:!self.giftAnimationBtn.selected forKey:@"CloseIdolBoxAnimation"];
}

- (void)setWishBtnUserinterface:(BOOL)canTap
{
    self.openBtn1.userInteractionEnabled = canTap;
    self.openBtn2.userInteractionEnabled = canTap;
    self.openBtn3.userInteractionEnabled = canTap;
}

#pragma mark - Svga动画
- (void)startOpenBoxAnimation
{
    self.isShowingSvga = YES;
    
    [self.svgaOpenBoxView stopAnimation];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.svgaBoxView.alpha = 0;
    });
    
    self.svgaOpenBoxView.imageName = @"prize_call_open_box";
}

- (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player
{
    self.isShowingSvga = NO;
    
    self.svgaBoxView.alpha = 1;
    
    [self checkHadShowResult];
}

#pragma mark - Network
- (void)openWishAction:(NSInteger)type
{
    if (self.isRequesting) {
        return;
    }
    
    self.isShowingSvga = YES;
    self.isRequesting = YES;
    if (self.giftAnimationBtn.selected) {
        [self startOpenBoxAnimation];
    }
    [self setWishBtnUserinterface:NO];
    
    __weak typeof(self) weakSelf = self;
    [JFHttpRequestHelper wish:type success:^(id data) {
        
        weakSelf.againType = type;
        weakSelf.isRequesting = NO;
        weakSelf.models = [data copy];
        
        // 请求优先于动画完成
        if (weakSelf.isShowingSvga) {
            // 延迟1秒弹出结果
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                // 取消动画
                weakSelf.svgaBoxView.alpha = 1;
                weakSelf.isShowingSvga = NO;
                [weakSelf.svgaOpenBoxView stopAnimation];
                
                // 弹窗
                [weakSelf checkHadShowResult];
            });
        } else {
            [weakSelf checkHadShowResult];
        }
        
    } failure:^(NSNumber *code, NSString *msg) {
        weakSelf.isRequesting = NO;
        [weakSelf setWishBtnUserinterface:YES];
    }];
}

/// 显示开箱子结果弹窗视图
- (void)checkHadShowResult
{
    if (self.isRequesting) {
        return;
    }
    
    if (self.models) {
        __weak typeof(self) weakSelf = self;
        [JFIdolProjectResultView showWish:self.models againType:self.againType buyBlock:^(NSInteger type) {
            [weakSelf openWishAction:type];
        }];
        
        self.models = nil;
        [self setWishBtnUserinterface:YES];
    }
}

@end
