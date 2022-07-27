//
//  JFMagicTableView.m
//  VoiceChat
//
//  Created by feng on 2020/9/6.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFMagicTableView.h"
#import <SVGAParser.h>
#import <SVGAImageView.h>
#import "SVGAVideoEntity.h"
#import "JFMagicTableResultView.h"
#import "JFHttpRequestHelper.h"

@interface JFMagicTableView () <SVGAPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *energyNumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *boxImageView;
@property (weak, nonatomic) IBOutlet SVGAImageView *svgaOpenBoxView;

@property (weak, nonatomic) IBOutlet UIButton *openBtn1;
@property (weak, nonatomic) IBOutlet UIButton *openBtn2;
@property (weak, nonatomic) IBOutlet UIButton *openBtn3;

@property (weak, nonatomic) IBOutlet UIButton *giftAnimationBtn;

@property (nonatomic,assign) BOOL isShowingSvga;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@end

@implementation JFMagicTableView

+ (void)show
{
    JFMagicTableView *view = [[NSBundle mainBundle] loadNibNamed:@"JFMagicTableView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    view.svgaOpenBoxView.delegate = view;
    
    view.contentView.alpha = 0;
    [view layoutIfNeeded];
    [UIView animateWithDuration:0.28 animations:^{
        view.contentView.alpha = 1;
        [view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - Event
/// 购买许愿币
- (IBAction)onTapBuyView:(id)sender {
    
}

/// 活动规则
- (IBAction)onClickRuleBtn:(id)sender
{
    
}

/// 关闭视图
- (IBAction)onClickCloseBtn:(id)sender
{
    [self removeFromSuperview];
}

/// 开启1次
- (IBAction)onClickOpenBtn1:(id)sender
{
    [self openWishAction:1];
}

/// 开启10次
- (IBAction)onClickOpenBtn2:(id)sender
{
    [self openWishAction:2];
}

/// 开启20次
- (IBAction)onClickOpenBtn3:(id)sender
{
    [self openWishAction:3];
}

/// 排行
- (IBAction)onClickRankBtn:(id)sender
{
    
}

/// 礼品
- (IBAction)onClickGiftBtn:(id)sender
{
    
}

/// 记录
- (IBAction)onClickRecordBtn:(id)sender
{
    
}

/// 礼物动画开关
- (IBAction)onClickAnimationSwitchBtn:(id)sender
{
    self.giftAnimationBtn.selected = !self.giftAnimationBtn.selected;
}

- (void)setWishBtnUserinterface:(BOOL)canTap
{
    self.openBtn1.userInteractionEnabled = canTap;
    self.openBtn2.userInteractionEnabled = canTap;
    self.openBtn3.userInteractionEnabled = canTap;
}

#pragma mark - Svga动画
- (void)startOpenBoxAnimation
{
    // 在请求接口成功后设置并调用播放动画方法
    self.isShowingSvga = YES;
    
    [self.svgaOpenBoxView stopAnimation];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.boxImageView.alpha = 0;
    });
    self.svgaOpenBoxView.imageName = @"magic_table_open";
}

- (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player
{
    self.isShowingSvga = NO;
    self.boxImageView.alpha = 1;
    [self checkHadShowResult];
}

#pragma mark - Network
- (void)openWishAction:(NSInteger)type
{
    if (self.giftAnimationBtn.selected) {
        self.isShowingSvga = YES;
        [self startOpenBoxAnimation];
    }
    
    [self setWishBtnUserinterface:NO];
    
    __weak typeof(self)weakSelf = self;
    [JFHttpRequestHelper wish:type success:^(id data) {
        
        weakSelf.models = [data copy];
        if (!self.giftAnimationBtn.selected) {
            [weakSelf checkHadShowResult];
        }
        
    } failure:^(NSNumber *code, NSString *msg) {
        [MBProgressHUD showError:msg];
        [weakSelf setWishBtnUserinterface:YES];
        weakSelf.isShowingSvga = NO;
    }];
}

- (void)checkHadShowResult
{
    if (self.isShowingSvga) {
        return;
    }
    
    if (self.models) {
        // 弹出结果视图
        __weak typeof(self)weakSelf =self;
        [JFMagicTableResultView showWish:self.models buyBlock:^(NSInteger type) {
            [weakSelf openWishAction:type];
        }];
        
        //延迟1s清，缓存
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setWishBtnUserinterface:YES];
            self.models = nil;
        });
        
    }
}

@end
