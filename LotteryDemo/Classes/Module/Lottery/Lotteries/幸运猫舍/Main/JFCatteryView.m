//
//  JFCatteryView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFCatteryView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "JFCatteryResultView.h"
#import <SVGAParser.h>
#import <SVGAImageView.h>
#import "SVGAVideoEntity.h"

#define CONTENT_VIEW_HEIGHT (kScreenWidth/(375.0/610.0))

@interface JFCatteryView () <SVGAPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;

@property (weak, nonatomic) IBOutlet UIButton *titleBtn1;
@property (weak, nonatomic) IBOutlet UIButton *titleBtn2;
@property (weak, nonatomic) IBOutlet UIButton *titleBtn3;

@property (weak, nonatomic) IBOutlet SVGAImageView *normalSvgaView;
@property (weak, nonatomic) IBOutlet SVGAImageView *feedingSvgaView;

@property (weak, nonatomic) IBOutlet UIButton *countBtn1;
@property (weak, nonatomic) IBOutlet UIButton *countBtn2;
@property (weak, nonatomic) IBOutlet UIButton *countBtn3;
@property (weak, nonatomic) IBOutlet UILabel *priceTipLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *left_stackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *right_stackView;

@property (nonatomic,assign) BOOL isRequesting;
@property (nonatomic,assign) BOOL isAnimation;
@property (nonatomic,assign) BOOL isBusy;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@property (nonatomic, assign) NSInteger level;

@end

@implementation JFCatteryView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.feedingSvgaView.delegate = self;
}

+ (void)show
{
    JFCatteryView *view = [[NSBundle mainBundle] loadNibNamed:@"JFCatteryView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    view.coverView.alpha = 0;
    view.bottom_contentView.constant = -CONTENT_VIEW_HEIGHT;
    [view layoutIfNeeded];
    [UIView animateWithDuration:0.28 animations:^{
        view.coverView.alpha = 1;
        view.bottom_contentView.constant = (iPhoneX ? 0 : -20);
        [view layoutIfNeeded];
    } completion:^(BOOL finished) {
        // 先从xib里加载一次结果单项视图，这样弹窗避免卡顿
        [UINib nibWithNibName:@"JFCatteryResultItemView" bundle:nil];
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
}

#pragma mark - Event
- (IBAction)onClickTitleBtn1:(id)sender
{
    if (self.isAnimation) {
        return;
    }
    self.level = 0;
    self.titleBtn1.selected = YES;
    self.titleBtn2.selected = NO;
    self.titleBtn3.selected = NO;
}

- (IBAction)onClickTitleBtn2:(id)sender
{
    if (self.isAnimation) {
        return;
    }
    self.level = 1;
    self.titleBtn1.selected = NO;
    self.titleBtn2.selected = YES;
    self.titleBtn3.selected = NO;
}

- (IBAction)onClickTitleBtn3:(id)sender
{
    if (self.isAnimation) {
        return;
    }
    self.level = 2;
    self.titleBtn1.selected = NO;
    self.titleBtn2.selected = NO;
    self.titleBtn3.selected = YES;
}

/// 点击次数按钮1
- (IBAction)onClickCountBtn1:(UIButton *)sender
{
    [self openWishAction:1];
}

/// 点击次数按钮2
- (IBAction)onClickCountBtn2:(UIButton *)sender
{
    [self openWishAction:2];
}

/// 点击次数按钮3
- (IBAction)onClickCountBtn3:(UIButton *)sender
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

#pragma mark - SVGAPlayerDelegate
- (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player
{
    if (self.isAnimation) {
        [self stopFeedingAnim];
        [self showResultView];
    }
}

- (void)startFeedingAnim
{
    self.isAnimation = YES;
    
    self.normalSvgaView.hidden = YES;
    self.feedingSvgaView.hidden = NO;
    
    [self.feedingSvgaView stopAnimation];
    switch (self.level) {
        case 0:
            self.feedingSvgaView.imageName = @"cattery_cat_feeding_0";
            break;
        case 1:
            self.feedingSvgaView.imageName = @"cattery_cat_feeding_1";
            break;
        case 2:
            self.feedingSvgaView.imageName = @"cattery_cat_feeding_2";
            break;
        default:
            break;
    }
}

- (void)stopFeedingAnim
{
    self.isAnimation = NO;
    
    self.normalSvgaView.hidden = NO;
    self.feedingSvgaView.hidden = YES;
}

#pragma mark - Network
- (void)openWishAction:(NSInteger)type
{
    if (self.isRequesting) {
        return;
    }
    self.isRequesting = YES;
    
    [self startFeedingAnim];
    [self setCountBtnUserInteractionEnabled:NO];
    
    __weak typeof(self) weakSelf = self;
    [JFHttpRequestHelper wish:type success:^(id data) {
        
        weakSelf.isRequesting = NO;
        weakSelf.models = data;
        
    } failure:^(NSNumber *code, NSString *msg) {
        weakSelf.isRequesting = NO;
        [weakSelf stopFeedingAnim];
        [weakSelf setCountBtnUserInteractionEnabled:YES];
        [MBProgressHUD showError:msg];
    }];
}

/// 显示结果弹窗
- (void)showResultView
{
    if (self.isRequesting) {
        return;
    }
    
    if (self.models) {
        __weak typeof(self) weakSelf = self;
        [JFCatteryResultView showWish:self.models callback:^{
            [weakSelf setCountBtnUserInteractionEnabled:YES];
        }];
        self.models = nil;
    }
}

- (void)setCountBtnUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    self.countBtn1.userInteractionEnabled = userInteractionEnabled;
    self.countBtn2.userInteractionEnabled = userInteractionEnabled;
    self.countBtn3.userInteractionEnabled = userInteractionEnabled;
}

#pragma mark - setter/geter
- (void)setLevel:(NSInteger)level
{
    _level = level;
    
    switch (level) {
        case 0:
            self.normalSvgaView.imageName = @"cattery_cat_normal_0";
            self.priceTipLabel.text = @"每喂食1次消耗5音符";
            break;
        case 1:
            self.normalSvgaView.imageName = @"cattery_cat_normal_1";
            self.priceTipLabel.text = @"每喂食1次消耗20音符";
            break;
        case 2:
            self.normalSvgaView.imageName = @"cattery_cat_normal_2";
            self.priceTipLabel.text = @"每喂食1次消耗50音符";
            break;
        default:
            break;
    }
}

@end
