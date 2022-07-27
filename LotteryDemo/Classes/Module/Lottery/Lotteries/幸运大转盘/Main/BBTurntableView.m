//
//  BBTurntableView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "BBTurntableView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "BBTurntableResultView.h"
#import "BBTurntableAnimView.h"

@interface BBTurntableView ()

@property (weak, nonatomic) IBOutlet BBTurntableAnimView *animView;

@property (weak, nonatomic) IBOutlet UIButton *openBtn1;
@property (weak, nonatomic) IBOutlet UIButton *openBtn2;
@property (weak, nonatomic) IBOutlet UIButton *openBtn3;

@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

/// 当前选中抽奖次数下标，0、1、2
@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, assign) BOOL isLuxury;

@end

@implementation BBTurntableView

+ (void)show
{
    BBTurntableView *view = [[NSBundle mainBundle] loadNibNamed:@"BBTurntableView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    view.selectedIndex = 0;
    [view monitorAnimViewEvent];
    
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
            case 2:
                [weakSelf openWishAction:5];
                break;
            default:
                break;
        }
    };
    
    self.animView.animStopBlock = ^{
        if (weakSelf.isRequesting || !weakSelf.models) {
            return;
        }
        
        // 弹出结果视图
        [BBTurntableResultView showWish:self.models];
        weakSelf.models = nil;
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

/// 抽奖1次
- (IBAction)onClickOpenBtn1:(id)sender
{
    self.selectedIndex = 0;
}

/// 抽奖10次
- (IBAction)onClickOpenBtn2:(id)sender
{
    self.selectedIndex = 1;
}

/// 抽奖100次
- (IBAction)onClickOpenBtn3:(id)sender
{
    self.selectedIndex = 2;
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
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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

#pragma mark - setter/getter
- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    
    switch (self.selectedIndex) {
        case 0:
            self.openBtn1.selected = YES;
            self.openBtn2.selected = NO;
            self.openBtn3.selected = NO;
            break;
        case 1:
            self.openBtn1.selected = NO;
            self.openBtn2.selected = YES;
            self.openBtn3.selected = NO;
            break;
        case 2:
            self.openBtn1.selected = NO;
            self.openBtn2.selected = NO;
            self.openBtn3.selected = YES;
            break;
        default:
            break;
    }
}

@end
