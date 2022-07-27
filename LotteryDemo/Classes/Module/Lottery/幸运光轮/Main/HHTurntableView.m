//
//  HHTurntableView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "HHTurntableView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "HHTurntableResultView.h"
#import "HHTurntableAnimView.h"
#import <SVGAImageView.h>

#define CONTENT_VIEW_HEIGHT (kScreenWidth/(360.0/460.0))

@interface HHTurntableView ()

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *animBtn;
@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;
@property (weak, nonatomic) IBOutlet HHTurntableAnimView *animView;

@property (weak, nonatomic) IBOutlet UIView *countPopupView;
@property (weak, nonatomic) IBOutlet UILabel *needAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_contentView;

@property (nonatomic,assign) BOOL isRequesting;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

/// 当前选中下标，0、1、2
@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation HHTurntableView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self onClickCountBtn1:nil];
}

+ (void)show
{
    HHTurntableView *view = [[NSBundle mainBundle] loadNibNamed:@"HHTurntableView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    view.animBtn.selected = [[NSUserDefaults standardUserDefaults] boolForKey:@"TURNTABLE_ANIM_STATUS"];
    view.animView.animStatus = view.animBtn.selected;

    [view monitorAnimViewEvent];
    
    view.coverView.alpha = 0;
    view.bottom_contentView.constant = -CONTENT_VIEW_HEIGHT;
    [view layoutIfNeeded];
    [UIView animateWithDuration:0.28 animations:^{
        view.coverView.alpha = 1;
        view.bottom_contentView.constant = 0;
        [view layoutIfNeeded];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeDialog) name:@"CloseRoomDialogView" object:nil];
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
    [self.animView destoryTimer];
}

#pragma mark - Event
/// 监听转盘回调事件
- (void)monitorAnimViewEvent
{
    __weak typeof(self)weakSelf = self;
    
    self.animView.tapGoBtnBlock = ^{
        switch (weakSelf.selectedIndex) {
            case 0:
                [weakSelf openWishAction:1];
                break;
            case 1:
                [weakSelf openWishAction:2];
                break;
            default:
                break;
        }
    };
    
    self.animView.animStopBlock = ^{
        [weakSelf showResultView];
    };
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

/// 动画开关
- (IBAction)onClickAnimBtn:(id)sender
{
    self.animBtn.selected = !self.animBtn.selected;
    self.animView.animStatus = self.animBtn.selected;
    [[NSUserDefaults standardUserDefaults] setBool:self.animBtn.selected forKey:@"TURNTABLE_ANIM_STATUS"];
}

- (IBAction)onClickCount:(id)sender {
    self.countPopupView.hidden = NO;
    self.countPopupView.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.countPopupView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)onClickCountBtn1:(id)sender
{
    self.selectedIndex = 0;
    self.countLabel.text = @"x1";
    self.needAmountLabel.text = @"2000";
    [self onClickCountBg:nil];
}

- (IBAction)onClickCountBtn2:(id)sender
{
    self.selectedIndex = 1;
    self.countLabel.text = @"x10";
    self.needAmountLabel.text = @"20000";
    [self onClickCountBg:nil];
}

- (IBAction)onClickCountBg:(id)sender {
    [UIView animateWithDuration:0.25 animations:^{
        self.countPopupView.alpha = 0;
    } completion:^(BOOL finished) {
        self.countPopupView.hidden = YES;
    }];
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
            weakSelf.models = data;
            
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

/// 显示结果弹窗
- (void)showResultView
{
    if (self.isRequesting) {
        return;
    }
    
    // 弹出结果视图
    if (self.models) {
        [HHTurntableResultView showWish:self.models];
        self.models = nil;
    }
}

@end
