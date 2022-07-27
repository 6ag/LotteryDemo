//
//  EETurntableView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "EETurntableView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "EETurntableResultView.h"
#import "EETurntableOptionView.h"
#import "EETurntableAnimView.h"

#define CONTENT_VIEW_HEIGHT (kScreenWidth/(375.0/570.0))

@interface EETurntableView ()

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *animBtn;
@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;

@property (weak, nonatomic) IBOutlet EETurntableAnimView *animView;
@property (weak, nonatomic) IBOutlet EETurntableOptionView *optionView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_contentView;

@property (nonatomic,assign) BOOL isRequesting;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@end

@implementation EETurntableView

+ (void)show
{
    EETurntableView *view = [[NSBundle mainBundle] loadNibNamed:@"EETurntableView" owner:self options:nil][0];
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
                [weakSelf openWishAction:3];
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
            [EETurntableResultView showWish:self.models];
            weakSelf.models = nil;
        }
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

/// 金币充值
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

@end
