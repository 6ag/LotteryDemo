//
//  JFTwistedEggView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFTwistedEggView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "JFTwistedEggResultView.h"
#import <SVGAParser.h>
#import <SVGAImageView.h>
#import "SVGAVideoEntity.h"
#import "JFTwistedEggOptionView.h"

@interface JFTwistedEggView () <SVGAPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *boxImageView;
@property (weak, nonatomic) IBOutlet SVGAImageView *svgaOpenBoxView;

@property (weak, nonatomic) IBOutlet JFTwistedEggOptionView *optionView;
@property (weak, nonatomic) IBOutlet GGButton *startTwistedBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_contentView;

@property (nonatomic,assign) BOOL isShowingSvga;
@property (nonatomic,assign) BOOL isRequesting;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@end

@implementation JFTwistedEggView

+ (void)show
{
    JFTwistedEggView *view = [[NSBundle mainBundle] loadNibNamed:@"JFTwistedEggView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    view.svgaOpenBoxView.delegate = view;
    
    view.coverView.alpha = 0;
    view.bottom_contentView.constant = -kScreenWidth/(414.0/590.0);
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
        self.bottom_contentView.constant = -kScreenWidth/(414.0/590.0);
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
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

- (IBAction)onClickStartTwistedBtn:(id)sender
{
    switch (self.optionView.selectedIndex) {
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

/// 切换喂食按钮交互
/// @param canTap 是否可以点击
- (void)setWishBtnUserinterface:(BOOL)canTap
{
    self.startTwistedBtn.userInteractionEnabled = canTap;
}

#pragma mark - Svga动画
- (void)startOpenBoxAnimation
{
    [self.svgaOpenBoxView stopAnimation];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.boxImageView.alpha = 0;
    });
    self.svgaOpenBoxView.imageName = @"room_twisted_egg_open_box";
}

- (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player
{
    self.isShowingSvga = NO;
    self.boxImageView.alpha = 1;
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
    [self startOpenBoxAnimation];
    [self setWishBtnUserinterface:NO];
    
    __weak typeof(self) weakSelf = self;
    [JFHttpRequestHelper wish:type success:^(id data) {
        
        weakSelf.isRequesting = NO;
        weakSelf.models = [data copy];
        
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
        // 弹出结果视图
        [JFTwistedEggResultView showWish:self.models];
        
        self.models = nil;
        [self setWishBtnUserinterface:YES];
    }
    
}

@end
