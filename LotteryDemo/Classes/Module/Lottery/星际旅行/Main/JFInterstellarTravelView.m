//
//  JFInterstellarTravelView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFInterstellarTravelView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import <SVGAParser.h>
#import <SVGAImageView.h>
#import "SVGAVideoEntity.h"
#import <AudioToolbox/AudioToolbox.h>
#import "JFInterstellarTravelResultItemView.h"

@interface JFInterstellarTravelView () <
SVGAPlayerDelegate,
UICollectionViewDelegateFlowLayout,
UICollectionViewDataSource,
UICollectionViewDelegate
>

@property (weak, nonatomic) IBOutlet UIButton *title1Btn;
@property (weak, nonatomic) IBOutlet UIButton *title2Btn;
@property (weak, nonatomic) IBOutlet UIButton *bgBtn;
@property (weak, nonatomic) IBOutlet UIButton *openBtn1;
@property (weak, nonatomic) IBOutlet UIButton *openBtn2;
@property (weak, nonatomic) IBOutlet UIButton *openBtn3;
@property (weak, nonatomic) IBOutlet UILabel *openPriceLabel1;
@property (weak, nonatomic) IBOutlet UILabel *openPriceLabel2;
@property (weak, nonatomic) IBOutlet UILabel *openPriceLabel3;


@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UICollectionView *resultCollectionView;

@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *boxImageView;
@property (weak, nonatomic) IBOutlet SVGAImageView *svgaOpenBoxView;

@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (nonatomic,assign) BOOL isRequesting;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@property (nonatomic, assign) BOOL isLuxury;

@end

@implementation JFInterstellarTravelView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.resultCollectionView registerNib:[UINib nibWithNibName:@"JFInterstellarTravelResultItemView" bundle:nil] forCellWithReuseIdentifier:@"JFInterstellarTravelResultItemView"];
    
    self.isLuxury = NO;
}

+ (void)show
{
    JFInterstellarTravelView *view = [[NSBundle mainBundle] loadNibNamed:@"JFInterstellarTravelView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view addNotification];
    view.svgaOpenBoxView.delegate = view;
    
    view.coverView.alpha = 0;
    [view layoutIfNeeded];
    [UIView animateWithDuration:0.28 animations:^{
        view.coverView.alpha = 1;
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
    [self removeFromSuperview];
}

#pragma mark - Event

- (IBAction)onClickTitle1Btn:(id)sender
{
    self.isLuxury = NO;
}
- (IBAction)onClickTitle2Btn:(id)sender
{
    self.isLuxury = YES;
}

/// 关闭视图
- (IBAction)onClickCloseBtn:(id)sender
{
    [self closeDialog];
}

- (IBAction)onClickMoreBtn:(id)sender
{
    
}

- (IBAction)onClickWishAction1:(id)sender
{
    [self openWishAction:1];
}

- (IBAction)onClickWishAction2:(id)sender
{
    [self openWishAction:2];
}

- (IBAction)onClickWishAction3:(id)sender
{
    [self openWishAction:5];
}

/// 切换喂食按钮交互
/// @param canTap 是否可以点击
- (void)setWishBtnUserinterface:(BOOL)canTap
{
    self.openBtn1.userInteractionEnabled = canTap;
    self.openBtn2.userInteractionEnabled = canTap;
    self.openBtn3.userInteractionEnabled = canTap;
}

#pragma mark - Network
- (void)openWishAction:(NSInteger)type
{
    if (self.isRequesting) {
        return;
    }
    self.isRequesting = YES;
    [self setWishBtnUserinterface:NO];
    
    __weak typeof(self)weakSelf = self;
    [JFHttpRequestHelper wish:type success:^(id data) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.isRequesting = NO;
            weakSelf.models = data;
            [weakSelf checkHadShowResult];
        });
        
    } failure:^(NSNumber *code, NSString *msg) {
        
        weakSelf.isRequesting = NO;
        [weakSelf setWishBtnUserinterface:YES];
        [MBProgressHUD showError:msg];
    }];
}

/// 显示开箱子结果
- (void)checkHadShowResult
{
    if (self.isRequesting) {
        return;
    }
    
    if (self.models) {
        self.boxImageView.hidden = YES;
        self.title1Btn.hidden = YES;
        self.title2Btn.hidden = YES;
        
        self.svgaOpenBoxView.hidden = NO;
        self.totalPriceLabel.hidden = NO;
        self.resultCollectionView.hidden = NO;
        
        [self calcTotalPrice];
        [self.resultCollectionView reloadData];
        [self setWishBtnUserinterface:YES];
    }
}

// 计算礼物总价值
- (void)calcTotalPrice
{
    NSInteger totalPrice = 0;
    BOOL needShake = NO;
    for (JFLotteryResultItem *item in self.models) {
        
        // 判断礼物价值是否需要开启震动
        if (item.goldPrice >= 5000) {
            needShake = YES;
        }
        
        // 计算总价值
        totalPrice += item.goldPrice * item.num;
    }
    
    if (needShake) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    self.totalPriceLabel.text = [NSString stringWithFormat:@"礼物总值:%ld", totalPrice];
}

#pragma mark - <UICollectionViewDelegate && UICollectionViewDataSource && UICollectionViewDelegateFlowLayout>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JFInterstellarTravelResultItemView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JFInterstellarTravelResultItemView" forIndexPath:indexPath];
    cell.model = self.models[indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = (kScreenWidth - 100 - 8 * 2) / 3;
    return CGSizeMake(itemWidth, itemWidth + JFWidthRadio(30));
}

// 滚动方向的item间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0.01;
}

// 滚动方向的交叉方向的item间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 8;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)setIsLuxury:(BOOL)isLuxury
{
    _isLuxury = isLuxury;
    
    if (isLuxury) {
        self.title1Btn.selected = NO;
        self.title2Btn.selected = YES;
        self.bgBtn.selected = YES;
        self.openBtn1.selected = YES;
        self.openBtn2.selected = YES;
        self.openBtn3.selected = YES;
        self.openPriceLabel1.text = @"20 金币";
        self.openPriceLabel2.text = @"200 金币";
        self.openPriceLabel3.text = @"2000 金币";
    } else {
        self.title1Btn.selected = YES;
        self.title2Btn.selected = NO;
        self.bgBtn.selected = NO;
        self.openBtn1.selected = NO;
        self.openBtn2.selected = NO;
        self.openBtn3.selected = NO;
        self.openPriceLabel1.text = @"10 金币";
        self.openPriceLabel2.text = @"100 金币";
        self.openPriceLabel3.text = @"1000 金币";
    }
}

@end
