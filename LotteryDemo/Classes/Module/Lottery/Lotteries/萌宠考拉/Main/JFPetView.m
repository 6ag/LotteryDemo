//
//  JFPetView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFPetView.h"
#import <SVGAPlayer/SVGAParser.h>
#import <SVGAPlayer/SVGAImageView.h>
#import <SVGAPlayer/SVGAVideoEntity.h>
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "JFPetResultView.h"

@interface JFPetView () <SVGAPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIView *coverView;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet SVGAImageView *characterIdelSvgaView;
@property (weak, nonatomic) IBOutlet SVGAImageView *characterEatSvgaView;
@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;
@property (weak, nonatomic) IBOutlet JFNoHighlightButton *animSwitchBtn;

@property (weak, nonatomic) IBOutlet UIButton *eat1Btn;
@property (weak, nonatomic) IBOutlet UIButton *eat10Btn;
@property (weak, nonatomic) IBOutlet UIButton *eat100Btn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_contentView;

@property (nonatomic,assign) BOOL isShowingSvga;
@property (nonatomic,assign) BOOL isRequesting;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;
@property (assign,nonatomic) NSInteger againType;
@end

@implementation JFPetView

+ (void)show
{
    JFPetView *view = [[NSBundle mainBundle] loadNibNamed:@"JFPetView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view addNotification];
    
    view.animSwitchBtn.selected = ![[NSUserDefaults standardUserDefaults] boolForKey:@"ClosePetEatAnimation"];
    
    view.characterEatSvgaView.delegate = view;
    view.coverView.alpha = 0;
    view.bottom_contentView.constant = -(iPhoneX ? 530 : 510);
    [view layoutIfNeeded];
    [UIView animateWithDuration:0.28 animations:^{
        view.coverView.alpha = 1;
        view.bottom_contentView.constant = (iPhoneX ? 0 : -20);
        [view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
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
        self.bottom_contentView.constant = -(iPhoneX ? 530 : 510);
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Event
/// 关闭视图
- (IBAction)onClickCloseBtn:(id)sender
{
    [self closeDialog];
}

/// 提示
- (IBAction)onClickTipBtn:(id)sender
{
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

/// 喂1次
- (IBAction)onClickEat1Btn:(id)sender
{
    [self openWishAction:1];
}

/// 喂10次
- (IBAction)onClickEat10Btn:(id)sender
{
    [self openWishAction:2];
}

/// 喂100次
- (IBAction)onClickEat100Btn:(id)sender
{
    [self openWishAction:5];
}

/// 动画切换
- (IBAction)onClickAnimSwitchBtn:(id)sender {
    self.animSwitchBtn.selected = !self.animSwitchBtn.isSelected;
    [[NSUserDefaults standardUserDefaults] setBool:!self.animSwitchBtn.selected forKey:@"ClosePetEatAnimation"];
}

/// 切换喂食按钮交互
/// @param canTap 是否可以点击
- (void)setWishBtnUserinterface:(BOOL)canTap
{
    self.eat1Btn.userInteractionEnabled = canTap;
    self.eat10Btn.userInteractionEnabled = canTap;
    self.eat100Btn.userInteractionEnabled = canTap;
}

#pragma mark - Svga动画
- (void)startOpenBoxAnimation
{
    [self.characterEatSvgaView stopAnimation];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.characterIdelSvgaView.alpha = 0;
    });
    
    self.characterEatSvgaView.imageName = @"room_pet_eat";
}

- (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player
{
    self.isShowingSvga = NO;
    
    self.characterIdelSvgaView.alpha = 1;
    
    [self checkHadShowResult];
}

#pragma mark - Network
- (void)openWishAction:(NSInteger)type
{
    if (self.isRequesting) {
        return;
    }
    
    self.isShowingSvga = YES;
    self.isRequesting = YES;
    if (self.animSwitchBtn.selected) {
        [self startOpenBoxAnimation];
    }
    [self setWishBtnUserinterface:NO];
    
    __weak typeof(self) weakSelf = self;
    [JFHttpRequestHelper wish:type success:^(id data) {
        weakSelf.isRequesting = NO;
        weakSelf.againType = type;
        weakSelf.models = [data copy];
        
        if (!weakSelf.animSwitchBtn.selected) {
            [weakSelf checkHadShowResult];
        }
        
    } failure:^(NSNumber *code, NSString *msg) {
        weakSelf.isRequesting = NO;
        [weakSelf setWishBtnUserinterface:YES];
        [MBProgressHUD showError:msg];
    }];
}

/// 显示开箱子结果弹窗视图
- (void)checkHadShowResult
{
    if (self.isRequesting) {
        return;
    }
    
    if (self.models) {
        // 弹出结果视图
        __weak typeof(self) weakSelf = self;
        [JFPetResultView showWish:self.models againType:self.againType buyBlock:^(NSInteger type) {
            [weakSelf openWishAction:type];
        } closeBlock:^{
            [weakSelf closeDialog];
        }];
        
        self.models = nil;
        [self setWishBtnUserinterface:YES];
    }
}

@end
