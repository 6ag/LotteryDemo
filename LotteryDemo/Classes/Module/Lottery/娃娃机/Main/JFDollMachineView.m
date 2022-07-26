//
//  JFDollMachineView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFDollMachineView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "JFDollMachineResultView.h"

#define CONTENT_VIEW_HEIGHT (kScreenWidth/(375.0/570.0))

@interface JFDollMachineView ()

@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn1;
@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn2;

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIImageView *bgImg;
@property (weak, nonatomic) IBOutlet UIImageView *noticeImg;
@property (weak, nonatomic) IBOutlet UIImageView *popupImg;
@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet UIView *popupCoverView;

@property (weak, nonatomic) IBOutlet UIButton *countBtn1;
@property (weak, nonatomic) IBOutlet UIButton *countBtn2;
@property (weak, nonatomic) IBOutlet UIButton *countBtn3;
@property (weak, nonatomic) IBOutlet UILabel *countPriceLabel1;
@property (weak, nonatomic) IBOutlet UILabel *countPriceLabel2;
@property (weak, nonatomic) IBOutlet UILabel *countPriceLabel3;

@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;

@property (weak, nonatomic) IBOutlet UILabel *goldBalanceTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rechargeAddImg;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_contentView;

@property (nonatomic,assign) BOOL isRequesting;

@property (nonatomic, assign) BOOL isLuxury;

@property (nonatomic, assign) NSInteger countOption;

@end

@implementation JFDollMachineView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.isLuxury = YES;
    self.countOption = 1;
}

+ (void)show
{
    JFDollMachineView *view = [[NSBundle mainBundle] loadNibNamed:@"JFDollMachineView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
 
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

- (IBAction)onClickMoreBtn:(id)sender
{
    self.popupView.hidden = NO;
    self.popupCoverView.hidden = NO;
}

- (IBAction)onClickPopupCoverView:(id)sender
{
    self.popupView.hidden = YES;
    self.popupCoverView.hidden = YES;
}

/// 关闭视图
- (IBAction)onClickCloseBtn:(id)sender
{
    [self closeDialog];
}

/// 礼物
- (IBAction)onClickGiftBtn:(id)sender
{
    [self onClickPopupCoverView:nil];
}

/// 记录
- (IBAction)onClickRecordBtn:(id)sender
{
    [self onClickPopupCoverView:nil];
}

/// 排行
- (IBAction)onClickRankBtn:(id)sender
{
    [self onClickPopupCoverView:nil];
}

/// 规则
- (IBAction)onClickRuleBtn:(id)sender
{
    [self onClickPopupCoverView:nil];
}

/// 红音符充值
- (IBAction)onClickCoinBtn:(id)sender
{
    
}

- (IBAction)onClickCountBtn1:(id)sender
{
    self.countOption = 1;
    self.countBtn1.selected = YES;
    self.countBtn2.selected = NO;
    self.countBtn3.selected = NO;
}

- (IBAction)onClickCountBtn2:(id)sender
{
    self.countOption = 2;
    self.countBtn1.selected = NO;
    self.countBtn2.selected = YES;
    self.countBtn3.selected = NO;
}

- (IBAction)onClickCountBtn3:(id)sender
{
    self.countOption = 5;
    self.countBtn1.selected = NO;
    self.countBtn2.selected = NO;
    self.countBtn3.selected = YES;
}

- (IBAction)onClickStartBtn:(id)sender
{
    [self openWishAction:self.countOption];
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
        [JFDollMachineResultView showWish:[data copy]];
        
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

- (void)setupMaterial
{
    if (self.isLuxury) {
        self.bgImg.image = [UIImage imageNamed:@"doll_machine_open_bg_luxury"];
        self.noticeImg.image = [UIImage imageNamed:@"doll_machine_open_notice_luxury"];
        [self.moreBtn setImage:[UIImage imageNamed:@"doll_machine_open_more_luxury"] forState:UIControlStateNormal];
        self.popupImg.image = [UIImage imageNamed:@"doll_machine_open_popup_luxury"];
        self.rechargeAddImg.image = [UIImage imageNamed:@"doll_machine_open_recharge_luxury"];
        [self.startBtn setImage:[UIImage imageNamed:@"doll_machine_open_start_luxury"] forState:UIControlStateNormal];
        self.countPriceLabel1.text = @"500";
        self.countPriceLabel2.text = @"5000";
        self.countPriceLabel3.text = @"50000";
        self.countPriceLabel1.textColor = UIColorHex(#7A3D0F);
        self.countPriceLabel2.textColor = UIColorHex(#7A3D0F);
        self.countPriceLabel3.textColor = UIColorHex(#7A3D0F);
        self.goldBalanceTipLabel.textColor = UIColorHex(#7A3D0F);
        self.goldBalanceLabel.textColor = UIColorHex(#7A3D0F);
    } else {
        self.bgImg.image = [UIImage imageNamed:@"doll_machine_open_bg_normal"];
        self.noticeImg.image = [UIImage imageNamed:@"doll_machine_open_notice_normal"];
        [self.moreBtn setImage:[UIImage imageNamed:@"doll_machine_open_more_normal"] forState:UIControlStateNormal];
        self.popupImg.image = [UIImage imageNamed:@"doll_machine_open_popup_normal"];
        self.rechargeAddImg.image = [UIImage imageNamed:@"doll_machine_open_recharge_normal"];
        [self.startBtn setImage:[UIImage imageNamed:@"doll_machine_open_start_normal"] forState:UIControlStateNormal];
        self.countPriceLabel1.text = @"20";
        self.countPriceLabel2.text = @"200";
        self.countPriceLabel3.text = @"2000";
        self.countPriceLabel1.textColor = UIColorHex(#FFFFFF);
        self.countPriceLabel2.textColor = UIColorHex(#FFFFFF);
        self.countPriceLabel3.textColor = UIColorHex(#FFFFFF);
        self.goldBalanceTipLabel.textColor = UIColorHex(#FFFFFF);
        self.goldBalanceLabel.textColor = UIColorHex(#FFFFFF);
    }
}

@end
