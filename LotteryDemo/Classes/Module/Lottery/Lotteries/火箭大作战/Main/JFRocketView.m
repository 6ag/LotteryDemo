//
//  JFRocketView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFRocketView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "JFRocketResultView.h"

@interface JFRocketView ()

@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn1;
@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn2;

@property (weak, nonatomic) IBOutlet UILabel *unitPriceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@property (weak, nonatomic) IBOutlet UIButton *openBtn1;
@property (weak, nonatomic) IBOutlet UIButton *openBtn2;
@property (weak, nonatomic) IBOutlet UIButton *openBtn3;

@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@property (nonatomic,assign) BOOL isRequesting;
@property (nonatomic, assign) BOOL isLuxury;

@end

@implementation JFRocketView

+ (void)show
{
    JFRocketView *view = [[NSBundle mainBundle] loadNibNamed:@"JFRocketView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
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
        self.bgImageView.image = [UIImage imageNamed:@"turntable_open_bg_luxury"];
        self.unitPriceLabel.text = @"200红音符一次，连开机会更高";
    } else {
        self.bgImageView.image = [UIImage imageNamed:@"turntable_open_bg_normal"];
        self.unitPriceLabel.text = @"20红音符一次，连开机会更高";
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
    if (self.isRequesting) {
        return;
    }
    self.isRequesting = YES;
    
    __weak typeof(self) weakSelf = self;
    [JFHttpRequestHelper wish:type success:^(id data) {
        
        weakSelf.isRequesting = NO;
        weakSelf.models = [data copy];
        
        if (weakSelf.models) {
            [JFRocketResultView showWish:weakSelf.models type:type againBlock:^(NSInteger type) {
                [weakSelf openWishAction:type];
            }];
            weakSelf.models = nil;
        }
    } failure:^(NSNumber *code, NSString *msg) {
        weakSelf.isRequesting = NO;
        [MBProgressHUD showError:msg];
    }];
}

#pragma mark - setter/getter
- (void)setIsLuxury:(BOOL)isLuxury
{
    _isLuxury = isLuxury;
    [self setupMaterial];
}

@end
