//
//  CCTreasureBoxView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "CCTreasureBoxView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "CCTreasureBoxResultView.h"
#import <SVGAParser.h>
#import <SVGAImageView.h>
#import "SVGAVideoEntity.h"

#define CONTENT_VIEW_HEIGHT (kScreenWidth/(375.0/430.0))

@interface CCTreasureBoxView () <SVGAPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn1;
@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn2;
@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn3;

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
@property (nonatomic, assign) NSInteger level;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@end

@implementation CCTreasureBoxView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.openSvgaImageView.delegate = self;
}

+ (void)show
{
    CCTreasureBoxView *view = [[NSBundle mainBundle] loadNibNamed:@"CCTreasureBoxView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    CGPoint center = CGPointMake(SCREEN_WIDTH * 0.5, CONTENT_VIEW_HEIGHT * 0.5 + 15);
    view.openSvgaImageView.frame = CGRectMake(0, 0, JFWidthRadio(220), JFWidthRadio(220));
    view.openSvgaImageView.center = center;
    
    view.coverView.alpha = 0;
    view.bottom_contentView.constant = -CONTENT_VIEW_HEIGHT;
    [view layoutIfNeeded];
    [UIView animateWithDuration:0.28 animations:^{
        view.coverView.alpha = 1;
        view.bottom_contentView.constant = (iPhoneX ? 0 : -20);
        [view layoutIfNeeded];
    } completion:^(BOOL finished) {
        view.level = 1;
    }];
    
    [view setupTurntableImageViewAnim];
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
- (IBAction)onClickType1Btn:(id)sender
{
    if (self.level == 1) {
        return;
    }
    self.level = 1;
}

- (IBAction)onClickType1Bt2:(id)sender
{
    if (self.level == 2) {
        return;
    }
    self.level = 2;
}

- (IBAction)onClickType1Bt3:(id)sender
{
    if (self.level == 3) {
        return;
    }
    self.level = 3;
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
    
    switch (self.level) {
        case 1:
            self.openSvgaImageView.imageName = @"cc_treasure_box_open_1";
            break;
        case 2:
            self.openSvgaImageView.imageName = @"cc_treasure_box_open_2";
            break;
        case 3:
            self.openSvgaImageView.imageName = @"cc_treasure_box_open_3";
            break;
        default:
            break;
    }
    self.openSvgaImageView.hidden = NO;
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
    if (self.models) {
        __weak typeof(self) weakSelf = self;
        [CCTreasureBoxResultView showWish:self.models callback:^{
            [weakSelf setCountBtnUserInteractionEnabled:YES];
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
    [self startAnimation];
    [self setCountBtnUserInteractionEnabled:NO];
    
    __weak typeof(self) weakSelf = self;
    [JFHttpRequestHelper wish:type success:^(id data) {

        weakSelf.isRequesting = NO;
        weakSelf.models = data;
        
        if (weakSelf.isAnimation) {
            [weakSelf stopAnimation];
            [weakSelf showResultView];
        }
        
    } failure:^(NSNumber *code, NSString *msg) {
        weakSelf.isRequesting = NO;
        [weakSelf stopAnimation];
        [weakSelf setCountBtnUserInteractionEnabled:YES];
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
    switch (self.level) {
        case 1:
            self.navSwitchBtn1.selected = YES;
            self.navSwitchBtn2.selected = NO;
            self.navSwitchBtn3.selected = NO;
            self.turntableImageView.image = [UIImage imageNamed:@"cc_treasure_box_open_rotation_1"];
            self.priceTipLabel.text = @"每开1次消耗20红音符";
            break;
        case 2:
            self.navSwitchBtn1.selected = NO;
            self.navSwitchBtn2.selected = YES;
            self.navSwitchBtn3.selected = NO;
            self.turntableImageView.image = [UIImage imageNamed:@"cc_treasure_box_open_rotation_2"];
            self.priceTipLabel.text = @"每开1次消耗50红音符";
            break;
        case 3:
            self.navSwitchBtn1.selected = NO;
            self.navSwitchBtn2.selected = NO;
            self.navSwitchBtn3.selected = YES;
            self.turntableImageView.image = [UIImage imageNamed:@"cc_treasure_box_open_rotation_3"];
            self.priceTipLabel.text = @"每开1次消耗200红音符";
            break;
        default:
            break;
    }
}

@end
