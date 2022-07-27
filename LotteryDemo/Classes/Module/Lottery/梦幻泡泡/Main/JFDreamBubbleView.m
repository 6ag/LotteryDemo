//
//  JFDreamBubbleView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFDreamBubbleView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "JFDreamBubbleResultView.h"
#import <SVGAParser.h>
#import <SVGAImageView.h>
#import "SVGAVideoEntity.h"

@interface JFDreamBubbleView ()

@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn1;
@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn2;

@property (weak, nonatomic) IBOutlet SVGAImageView *svgaBoxView;

@property (weak, nonatomic) IBOutlet UIButton *openBtn1;
@property (weak, nonatomic) IBOutlet UIButton *openBtn2;
@property (weak, nonatomic) IBOutlet UIButton *openBtn3;
@property (weak, nonatomic) IBOutlet UILabel *openPriceLabel;

@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, assign) BOOL isLuxury;

@property (nonatomic, assign) NSInteger type;

@end

@implementation JFDreamBubbleView

+ (void)show
{
    JFDreamBubbleView *view = [[NSBundle mainBundle] loadNibNamed:@"JFDreamBubbleView" owner:self options:nil][0];
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
    }];
}

#pragma mark - UI
- (void)setupMaterial
{
    if (self.isLuxury) {
        self.svgaBoxView.imageName = @"dream_bubble_open_box_idel_luxury";
        self.openPriceLabel.text = @"抽1次50红音符";
        self.navSwitchBtn1.selected = NO;
        self.navSwitchBtn2.selected = YES;
    } else {
        self.svgaBoxView.imageName = @"dream_bubble_open_box_idel_normal";
        self.openPriceLabel.text = @"抽1次20红音符";
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

- (IBAction)onClickGoldView:(id)sender
{
    
}

- (void)setBtnUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    self.openBtn1.userInteractionEnabled = userInteractionEnabled;
    self.openBtn2.userInteractionEnabled = userInteractionEnabled;
    self.openBtn3.userInteractionEnabled = userInteractionEnabled;
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
    self.isRequesting = YES;
    [self setBtnUserInteractionEnabled:NO];
    
    __weak typeof(self) weakSelf = self;
    [JFHttpRequestHelper wish:self.type success:^(id data) {
        
        weakSelf.isRequesting = NO;
        weakSelf.models = [data copy];
        [weakSelf checkHadShowResult];
        
    } failure:^(NSNumber *code, NSString *msg) {
        weakSelf.isRequesting = NO;
        [weakSelf setBtnUserInteractionEnabled:YES];
        [MBProgressHUD showError:msg];
    }];
}

int test = 1;

/// 显示开箱子结果弹窗视图
- (void)checkHadShowResult
{
    if (self.isRequesting) {
        return;
    }
    
    if (self.models) {
        __weak typeof(self) weakSelf = self;
        [JFDreamBubbleResultView showWish:self.models isLuxury:self.isLuxury finished:^{
            [weakSelf setBtnUserInteractionEnabled:YES];
        }];
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
