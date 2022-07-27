//
//  JFUnlimitedTreasureChestView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFUnlimitedTreasureChestView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "JFUnlimitedTreasureChestResultView.h"
#import <SVGAParser.h>
#import <SVGAImageView.h>
#import "SVGAVideoEntity.h"

#define CONTENT_VIEW_HEIGHT (kScreenWidth/(375.0/330.0))

@interface JFUnlimitedTreasureChestView () <SVGAPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn1;
@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn2;
@property (weak, nonatomic) IBOutlet JFNoHighlightButton *animBtn;

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *turntableImageView;
@property (weak, nonatomic) IBOutlet SVGAImageView *openSvgaImageView;

@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;

@property (weak, nonatomic) IBOutlet UIButton *optionBtn1;
@property (weak, nonatomic) IBOutlet UIButton *optionBtn2;
@property (weak, nonatomic) IBOutlet UIButton *optionBtn3;
@property (weak, nonatomic) IBOutlet UILabel *priceTipLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_contentView;

@property (nonatomic, assign) BOOL isAnimation;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, assign) BOOL isLuxury;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@end

@implementation JFUnlimitedTreasureChestView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.isLuxury = YES;
    self.openSvgaImageView.delegate = self;
}

+ (void)show
{
    JFUnlimitedTreasureChestView *view = [[NSBundle mainBundle] loadNibNamed:@"JFUnlimitedTreasureChestView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    view.animBtn.selected = [[NSUserDefaults standardUserDefaults] boolForKey:@"TWISTED_EGG_ANIM_STATUS"];
    
    view.coverView.alpha = 0;
    view.bottom_contentView.constant = -CONTENT_VIEW_HEIGHT - 35;
    [view layoutIfNeeded];
    [UIView animateWithDuration:0.28 animations:^{
        view.coverView.alpha = 1;
        view.bottom_contentView.constant = (iPhoneX ? 35 : 55);
        [view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
    
    [view setupTurntableImageViewAnim];
}

- (void)closeDialog
{
    [UIView animateWithDuration:0.28 animations:^{
        self.coverView.alpha = 0;
        self.bottom_contentView.constant = -CONTENT_VIEW_HEIGHT - 35;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Event
- (IBAction)onClickNormalBtn:(id)sender
{
    self.isLuxury = NO;
}

- (IBAction)onClickLuxuryBtn:(id)sender
{
    self.isLuxury = YES;
}

/// 关闭视图
- (IBAction)onClickCloseBtn:(id)sender
{
    [self closeDialog];
}

- (IBAction)onClickGiftBtn:(id)sender {
    
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

// 1次
- (IBAction)onClickOptionBtn1:(id)sender {
    [self openWishAction:1];
}

// 10次
- (IBAction)onClickOptionBtn2:(id)sender {
    [self openWishAction:2];
}

// 100次
- (IBAction)onClickOptionBtn3:(id)sender {
    [self openWishAction:5];
}

- (IBAction)onClickAnimBtn:(id)sender {
    self.animBtn.selected = !self.animBtn.selected;
    [[NSUserDefaults standardUserDefaults] setBool:self.animBtn.selected forKey:@"TWISTED_EGG_ANIM_STATUS"];
}

- (void)setCountBtnUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    self.optionBtn1.userInteractionEnabled = userInteractionEnabled;
    self.optionBtn2.userInteractionEnabled = userInteractionEnabled;
    self.optionBtn3.userInteractionEnabled = userInteractionEnabled;
}

- (void)setupTurntableImageViewAnim
{
    CGPoint center = CGPointMake(SCREEN_WIDTH * 0.5, CONTENT_VIEW_HEIGHT * 0.5 + 15);
    self.turntableImageView.center = center;
    
    CABasicAnimation * ani = [CABasicAnimation animationWithKeyPath:@"position"];
    ani.toValue = [NSValue valueWithCGPoint:CGPointMake(center.x, center.y + 20)];
    ani.duration = 2.0f;
    ani.autoreverses = YES;
    ani.repeatCount = HUGE_VALF;
    ani.removedOnCompletion = NO;
    ani.fillMode = kCAFillModeForwards;
    ani.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.turntableImageView.layer addAnimation:ani forKey:@"box_postionY"];
}

#pragma mark - SVGAPlayerDelegate
- (void)startAnimation
{
    self.isAnimation = YES;
    self.turntableImageView.hidden = YES;
    
    self.openSvgaImageView.hidden = NO;
    [self.openSvgaImageView startAnimation];
}

- (void)stopAnimation
{
    self.isAnimation = NO;
    [self.openSvgaImageView stepToFrame:0 andPlay:NO];
    self.openSvgaImageView.hidden = YES;
    self.turntableImageView.hidden = NO;
}

- (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player
{
    if (self.isAnimation) {
        [self showResultView];
    }
    
    [self stopAnimation];
}

- (void)showResultView
{
    // 弹出结果视图
    if (self.models) {
        [JFUnlimitedTreasureChestResultView showWish:self.models callback:^{
            [self setCountBtnUserInteractionEnabled:YES];
        }];
        self.models = nil;
    }
}

#pragma mark - Network
- (void)openWishAction:(NSInteger)type
{
    if (self.isRequesting) {
        return;
    }
    self.isRequesting = YES;
    if (!self.animBtn.selected && self.isLuxury) {
        [self startAnimation];
    }
    [self setCountBtnUserInteractionEnabled:NO];
    
    __weak typeof(self) weakSelf = self;
    [JFHttpRequestHelper wish:type success:^(id data) {
        
        weakSelf.isRequesting = NO;
        weakSelf.models = data;
        
        if (!weakSelf.animBtn.selected && weakSelf.isLuxury) {
            
        } else {
            [weakSelf showResultView];
        }
        
    } failure:^(NSNumber *code, NSString *msg) {
        weakSelf.isRequesting = NO;
        if (!weakSelf.animBtn.selected && weakSelf.isLuxury) {
            [weakSelf stopAnimation];
        }
        [weakSelf setCountBtnUserInteractionEnabled:YES];
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
        self.turntableImageView.image = [UIImage imageNamed:@"unlimited_treasure_chest_open_rotation_luxury"];
        self.priceTipLabel.text = @"每开1次消耗50红音符";
        self.animBtn.hidden = NO;
    } else {
        self.turntableImageView.image = [UIImage imageNamed:@"unlimited_treasure_chest_open_rotation_normal"];
        self.priceTipLabel.text = @"每开1次消耗20红音符";
        self.animBtn.hidden = YES;
    }
}

@end
