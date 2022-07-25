//
//  JFLuckyBottleView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFLuckyBottleView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "JFLuckyBottleResultView.h"

@interface JFLuckyBottleView ()

@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn1;
@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn2;

@property (weak, nonatomic) IBOutlet UIImageView *boxImageView;

@property (weak, nonatomic) IBOutlet UIButton *openBtn1;
@property (weak, nonatomic) IBOutlet UIButton *openBtn2;
@property (weak, nonatomic) IBOutlet UIButton *openBtn3;
@property (weak, nonatomic) IBOutlet UILabel *openLabel1;
@property (weak, nonatomic) IBOutlet UILabel *openLabel2;
@property (weak, nonatomic) IBOutlet UILabel *openLabel3;

@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@property (nonatomic,assign) BOOL isRequesting;
@property (nonatomic, assign) BOOL isLuxury;

@end

@implementation JFLuckyBottleView

+ (void)show
{
    JFLuckyBottleView *view = [[NSBundle mainBundle] loadNibNamed:@"JFLuckyBottleView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];

    view.alpha = 0;
    [UIView animateWithDuration:0.28 animations:^{
        view.alpha = 1;
    } completion:^(BOOL finished) {
        // 先从xib里加载一次结果单项视图，这样弹窗避免卡顿
        [UINib nibWithNibName:@"JFLuckyBottleResultItemView" bundle:nil];
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
        self.boxImageView.image = [UIImage imageNamed:@"lucky_bottle_open_box_luxury"];
        self.openLabel1.text = @"200红钻";
        self.openLabel2.text = @"2000红钻";
        self.openLabel3.text = @"20000红钻";
        self.navSwitchBtn1.selected = NO;
        self.navSwitchBtn2.selected = YES;
    } else {
        self.boxImageView.image = [UIImage imageNamed:@"lucky_bottle_open_box_normal"];
        self.openLabel1.text = @"20红钻";
        self.openLabel2.text = @"200红钻";
        self.openLabel3.text = @"2000红钻";
        self.navSwitchBtn1.selected = YES;
        self.navSwitchBtn2.selected = NO;
    }
    
    self.openBtn1.selected = self.isLuxury;
    self.openBtn2.selected = self.isLuxury;
    self.openBtn3.selected = self.isLuxury;
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
            [JFLuckyBottleResultView showWish:weakSelf.models type:type againBlock:^(NSInteger type) {
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
