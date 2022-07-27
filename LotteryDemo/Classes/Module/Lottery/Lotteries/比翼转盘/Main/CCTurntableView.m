//
//  CCTurntableView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "CCTurntableView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "CCTurntableResultView.h"
#import "CCTurntableOptionView.h"
#import "CCTurntableAnimView.h"

#define CONTENT_VIEW_HEIGHT (kScreenWidth/(375.0/534.0))

@interface CCTurntableView ()

@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn1;
@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerX_lineView; // 自定义导航栏下划线图标中心约束

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;

@property (weak, nonatomic) IBOutlet CCTurntableAnimView *animView;
@property (weak, nonatomic) IBOutlet CCTurntableOptionView *optionView;

@property (weak, nonatomic) IBOutlet UIImageView *rechargeBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_contentView;

@property (nonatomic,assign) BOOL isRequesting;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@property (nonatomic, assign) BOOL isLuxury;

@end

@implementation CCTurntableView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.isLuxury = NO;
    
    [self setupBgView:self.contentView rect:CGRectMake(0, 0, kScreenWidth, CONTENT_VIEW_HEIGHT)];
}

- (void)setupBgView:(UIView *)view rect:(CGRect)rect
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(15, 15)];
    CAShapeLayer * maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = rect;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

+ (void)show
{
    CCTurntableView *view = [[NSBundle mainBundle] loadNibNamed:@"CCTurntableView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    [view monitorAnimViewEvent];
    
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
/// 监听转盘回调事件
- (void)monitorAnimViewEvent
{
    __weak typeof(self)weakSelf = self;
    
    self.animView.tapGoBtnBlock = ^{
        switch (weakSelf.optionView.selectedIndex) {
            case 0:
                [weakSelf openWishAction:1];
                break;
            case 1:
                [weakSelf openWishAction:2];
                break;
            case 2:
                [weakSelf openWishAction:5];
                break;
            default:
                break;
        }
    };
    
    self.animView.animStopBlock = ^{
        if (weakSelf.isRequesting) {
            return;
        }
        
        // 弹出结果视图
        if (weakSelf.models) {
            [CCTurntableResultView showWish:self.models];
            weakSelf.models = nil;
        }
    };
    
}

- (IBAction)onClickNormalBtn:(id)sender
{
    self.isLuxury = NO;
    
    self.navSwitchBtn1.selected = YES;
    self.navSwitchBtn2.selected = NO;
    
    [self setSelBarAnimation:0];
    
    self.navSwitchBtn1.titleLabel.font = JFFontPingFangSCRegular(16);
    self.navSwitchBtn2.titleLabel.font = JFFontPingFangSCRegular(14);
}

- (IBAction)onClickLuxuryBtn:(id)sender
{
    self.isLuxury = YES;
    
    self.navSwitchBtn1.selected = NO;
    self.navSwitchBtn2.selected = YES;
    
    [self setSelBarAnimation:1];
    
    self.navSwitchBtn1.titleLabel.font = JFFontPingFangSCRegular(14);
    self.navSwitchBtn2.titleLabel.font = JFFontPingFangSCRegular(16);
}

/// 自定义导航栏上的指示器滚动动画
- (void)setSelBarAnimation:(NSInteger)index
{
    [self.contentView layoutIfNeeded];
    
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.28 animations:^{
        if (index == 0) {
            weakSelf.centerX_lineView.constant = 0;
        } else if (index == 1) {
            weakSelf.centerX_lineView.constant = weakSelf.navSwitchBtn2.centerX - weakSelf.navSwitchBtn1.centerX;
        }
        [weakSelf.contentView layoutIfNeeded];
    }];
    
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
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.isRequesting = NO;
            weakSelf.models = [data copy];
            
            // 获取价值最大的礼物
            JFLotteryResultItem *mostExpensive = nil;
            NSInteger maxGoldPrice = 0;
            for (JFLotteryResultItem *item in weakSelf.models) {
                if (item.goldPrice > maxGoldPrice) {
                    maxGoldPrice = item.goldPrice;
                    mostExpensive = item;
                }
            }
            [weakSelf.animView stopAtGiftName:mostExpensive.itemName];
        });
        
    } failure:^(NSNumber *code, NSString *msg) {
        weakSelf.isRequesting = NO;
        [weakSelf.animView stopOfFailure];
        [MBProgressHUD showError:msg];
    }];
}

#pragma mark - setter/getter
- (void)setIsLuxury:(BOOL)isLuxury
{
    _isLuxury = isLuxury;

    self.animView.isLuxury = _isLuxury;
    self.optionView.isLuxury = _isLuxury;

    [self setupMaterial];
}

- (void)setupMaterial
{
    if (self.isLuxury) {
        [self.rechargeBtn setImage:[UIImage imageNamed:@"cc_turntable_open_recharge_luxury"]];
    } else {
        [self.rechargeBtn setImage:[UIImage imageNamed:@"cc_turntable_open_recharge_normal"]];
    }
}

@end
