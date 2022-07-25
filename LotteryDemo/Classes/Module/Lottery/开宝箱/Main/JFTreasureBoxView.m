//
//  JFTreasureBoxView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFTreasureBoxView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "JFTreasureBoxResultView.h"
#import <SVGAParser.h>
#import <SVGAImageView.h>
#import "SVGAVideoEntity.h"

@interface JFTreasureBoxView () <SVGAPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn1;
@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn2;

@property (weak, nonatomic) IBOutlet SVGAImageView *svgaBoxView;
@property (weak, nonatomic) IBOutlet SVGAImageView *svgaOpenBoxView;

@property (weak, nonatomic) IBOutlet UIButton *openBtn1;
@property (weak, nonatomic) IBOutlet UIButton *openBtn2;
@property (weak, nonatomic) IBOutlet UIButton *openBtn3;
@property (weak, nonatomic) IBOutlet UILabel *openLabel1;
@property (weak, nonatomic) IBOutlet UILabel *openLabel2;
@property (weak, nonatomic) IBOutlet UILabel *openLabel3;

@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@property (nonatomic, assign) BOOL isShowingSvga;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, assign) BOOL isLuxury;

@property (nonatomic, assign) NSInteger type;

@end

@implementation JFTreasureBoxView

+ (void)show
{
    JFTreasureBoxView *view = [[NSBundle mainBundle] loadNibNamed:@"JFTreasureBoxView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    view.svgaOpenBoxView.delegate = view;
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
    }];
}

#pragma mark - UI
- (void)setupMaterial
{
    if (self.isLuxury) {
        self.svgaBoxView.imageName = @"treasure_box_open_box_idel_luxury";
        self.openLabel1.text = @"1000向日葵";
        self.openLabel2.text = @"10000向日葵";
        self.openLabel3.text = @"100000向日葵";
        self.navSwitchBtn1.selected = NO;
        self.navSwitchBtn2.selected = YES;
    } else {
        self.svgaBoxView.imageName = @"treasure_box_open_box_idel_normal";
        self.openLabel1.text = @"5向日葵";
        self.openLabel2.text = @"50向日葵";
        self.openLabel3.text = @"500向日葵";
        self.navSwitchBtn1.selected = YES;
        self.navSwitchBtn2.selected = NO;
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

/// 抽奖1次
- (IBAction)onClickOpenBtn1:(id)sender
{
    [self openWishAction:1];
}

/// 抽奖10次
- (IBAction)onClickOpenBtn2:(id)sender
{
    [self openWishAction:2];
}

/// 抽奖100次
- (IBAction)onClickOpenBtn3:(id)sender
{
    [self openWishAction:5];
}

#pragma mark - Network
/// 抽奖请求
/// @param type 1-1次 2-10次 5-100次
- (void)openWishAction:(NSInteger)type
{
    self.type = type;
    
    if (self.isRequesting) {
        return;
    }
    self.isShowingSvga = YES;
    self.isRequesting = YES;
    [self startOpenBoxAnimation];
    
    __weak typeof(self) weakSelf = self;
    [JFHttpRequestHelper wish:self.type success:^(id data) {
        
        weakSelf.isRequesting = NO;
        weakSelf.models = [data copy];
        
    } failure:^(NSNumber *code, NSString *msg) {
        weakSelf.isRequesting = NO;
        [MBProgressHUD showError:msg];
    }];
}

#pragma mark - Svga动画
- (void)startOpenBoxAnimation
{
    self.isShowingSvga = YES;
    
    [self.svgaOpenBoxView stopAnimation];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.svgaBoxView.alpha = 0;
    });
    
    if (self.isLuxury) {
        self.svgaOpenBoxView.imageName = @"treasure_box_open_box_open_luxury";
    } else {
        self.svgaOpenBoxView.imageName = @"treasure_box_open_box_open_normal";
    }
}

- (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player
{
    self.isShowingSvga = NO;
    self.svgaBoxView.alpha = 1;
    
    [self checkHadShowResult];
}

/// 显示开箱子结果弹窗视图
- (void)checkHadShowResult
{
    if (self.isRequesting) {
        return;
    }
    
    if (self.models) {
        [JFTreasureBoxResultView showWish:self.models];
        self.models = nil;
    }
}

#pragma mark - setter/getter
- (void)setIsLuxury:(BOOL)isLuxury
{
    _isLuxury = isLuxury;
    [self setupMaterial];
}

@end
