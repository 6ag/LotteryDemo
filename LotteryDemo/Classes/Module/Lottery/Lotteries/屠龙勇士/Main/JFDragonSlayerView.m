//
//  JFDragonSlayerView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFDragonSlayerView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "JFDragonSlayerResultView.h"

#define CONTENT_VIEW_HEIGHT (kScreenWidth/(375.0/610.0))

@interface JFDragonSlayerView ()

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *normalBtn;
@property (weak, nonatomic) IBOutlet UIButton *luxuryBtn;
@property (weak, nonatomic) IBOutlet UIImageView *titleLineView;
@property (weak, nonatomic) IBOutlet UIImageView *centerImageView;

@property (weak, nonatomic) IBOutlet UILabel *costLabel1;
@property (weak, nonatomic) IBOutlet UILabel *costLabel2;
@property (weak, nonatomic) IBOutlet UILabel *costLabel3;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerX_titleLineView;

@property (nonatomic, assign) BOOL isRequesting;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@property (nonatomic, assign) BOOL isLuxury;

@end

@implementation JFDragonSlayerView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.isLuxury = NO;
}

+ (void)show
{
    JFDragonSlayerView *view = [[NSBundle mainBundle] loadNibNamed:@"JFDragonSlayerView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    view.nameLabel.text = @"这里是昵称";
    
    view.coverView.alpha = 0;
    view.bottom_contentView.constant = -CONTENT_VIEW_HEIGHT;
    [view layoutIfNeeded];
    [UIView animateWithDuration:0.28 animations:^{
        view.coverView.alpha = 1;
        view.bottom_contentView.constant = (iPhoneX ? 0 : -20);
        [view layoutIfNeeded];
    } completion:^(BOOL finished) {
        // 先从xib里加载一次结果单项视图，这样弹窗避免卡顿
        [UINib nibWithNibName:@"JFDragonSlayerResultItemView" bundle:nil];
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
- (IBAction)onClickNormalBtn:(id)sender
{
    [UIView animateWithDuration:0.25 animations:^{
        self.centerX_titleLineView.constant = -50;
        [self layoutIfNeeded];
    }];
    self.isLuxury = NO;
}

- (IBAction)onClickLuxuryBtn:(id)sender
{
    [UIView animateWithDuration:0.25 animations:^{
        self.centerX_titleLineView.constant = 50;
        [self layoutIfNeeded];
    }];
    self.isLuxury = YES;
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

/// 充值
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
            [JFDragonSlayerResultView showWish:weakSelf.models];
            weakSelf.models = nil;
        }
        
    } failure:^(NSNumber *code, NSString *msg) {
        weakSelf.isRequesting = NO;
        [MBProgressHUD showError:msg];
    }];
}

- (void)setIsLuxury:(BOOL)isLuxury
{
    _isLuxury = isLuxury;
    
    if (isLuxury) {
        self.normalBtn.alpha = 0.65;
        self.luxuryBtn.alpha = 1.0;
        self.centerImageView.image = [UIImage imageNamed:@"dragon_slayer_open_center_2"];
        self.costLabel1.text = @"1000红音符";
        self.costLabel2.text = @"10000红音符";
        self.costLabel3.text = @"100000红音符";
    } else {
        self.normalBtn.alpha = 1.0;
        self.luxuryBtn.alpha = 0.65;
        self.centerImageView.image = [UIImage imageNamed:@"dragon_slayer_open_center_1"];
        self.costLabel1.text = @"10红音符";
        self.costLabel2.text = @"100红音符";
        self.costLabel3.text = @"1000红音符";
    }
    
}

@end
