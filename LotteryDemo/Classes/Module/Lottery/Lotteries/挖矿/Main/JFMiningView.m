//
//  JFMiningView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFMiningView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "JFMiningResultView.h"

#define CONTENT_VIEW_HEIGHT (kScreenWidth/(375.0/520.0))

@interface JFMiningView ()

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIButton *switchBtn1;
@property (weak, nonatomic) IBOutlet UIButton *switchBtn2;
@property (weak, nonatomic) IBOutlet UIButton *switchBtn3;

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *costLabel1;
@property (weak, nonatomic) IBOutlet UILabel *costLabel2;
@property (weak, nonatomic) IBOutlet UILabel *costLabel3;

@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_contentView;

@property (nonatomic,assign) BOOL isRequesting;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@property (nonatomic, assign) NSInteger level; // 0 1 2

@end

@implementation JFMiningView

+ (void)show
{
    JFMiningView *view = [[NSBundle mainBundle] loadNibNamed:@"JFMiningView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];

    view.level = 1;
    
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
    }];
}

#pragma mark - Event
- (IBAction)onClickSwitchBtn1:(id)sender
{
    self.level = 0;
}

- (IBAction)onClickSwitchBtn2:(id)sender
{
    self.level = 1;
}

- (IBAction)onClickSwitchBtn3:(id)sender
{
    self.level = 2;
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

#pragma mark - Network
- (void)openWishAction:(NSInteger)type
{
    if (self.isRequesting) {
        return;
    }
    self.isRequesting = YES;
    
    __weak typeof(self) weakSelf = self;
    [JFHttpRequestHelper wish:type success:^(id data) {
        
        weakSelf.isRequesting = NO;
        weakSelf.models = data;

        if (weakSelf.models) {
            [JFMiningResultView showWish:weakSelf.models type:type againBlock:^(NSInteger type) {
                [weakSelf openWishAction:type];
            }];
            weakSelf.models = nil;
        }
        
    } failure:^(NSNumber *code, NSString *msg) {
        self.isRequesting = NO;
        [MBProgressHUD showError:msg];
    }];
}

#pragma mark - setter/getter
- (void)setLevel:(NSInteger)level
{
    _level = level;
    [self setupMaterial];
}

- (void)setupMaterial
{
    if (self.level == 0) {
        self.costLabel1.text = @"10 红音符";
        self.costLabel2.text = @"100 红音符";
        self.costLabel3.text = @"1000 红音符";
        self.bgImageView.image = [UIImage imageNamed:@"mining_open_bg_level_1"];
        
        self.switchBtn1.selected = YES;
        self.switchBtn2.selected = NO;
        self.switchBtn3.selected = NO;
    } else if (self.level == 1) {
        self.costLabel1.text = @"20 红音符";
        self.costLabel2.text = @"200 红音符";
        self.costLabel3.text = @"2000 红音符";
        self.bgImageView.image = [UIImage imageNamed:@"mining_open_bg_level_2"];
        
        self.switchBtn1.selected = NO;
        self.switchBtn2.selected = YES;
        self.switchBtn3.selected = NO;
    } else if (self.level == 2) {
        self.costLabel1.text = @"100 红音符";
        self.costLabel2.text = @"1000 红音符";
        self.costLabel3.text = @"10000 红音符";
        self.bgImageView.image = [UIImage imageNamed:@"mining_open_bg_level_3"];
        
        self.switchBtn1.selected = NO;
        self.switchBtn2.selected = NO;
        self.switchBtn3.selected = YES;
    }
}

@end
