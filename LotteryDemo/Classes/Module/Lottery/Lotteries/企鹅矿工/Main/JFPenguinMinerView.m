//
//  JFPenguinMinerView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFPenguinMinerView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "JFPenguinMinerResultView.h"
#import "JFPenguinMinerGiftListCCell.h"
#import <SVGAParser.h>
#import <SVGAImageView.h>
#import "SVGAVideoEntity.h"

#define CONTENT_VIEW_HEIGHT (kScreenWidth/(375.0/534.0))

@interface JFPenguinMinerView () <UICollectionViewDataSource, UICollectionViewDelegate, SVGAPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn1;
@property (weak, nonatomic) IBOutlet UIButton *navSwitchBtn2;

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *turntableImageView;
@property (weak, nonatomic) IBOutlet SVGAImageView *openSvgaImageView;

@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;

@property (weak, nonatomic) IBOutlet UIButton *optionBtn1;
@property (weak, nonatomic) IBOutlet UIButton *optionBtn2;
@property (weak, nonatomic) IBOutlet UIButton *optionBtn3;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel1;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel2;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel3;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_contentView;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray<JFLotteryResultItem *> *giftArray;

@property (nonatomic, assign) BOOL isAnimation;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, assign) BOOL isLuxury;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@end

@implementation JFPenguinMinerView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JFPenguinMinerGiftListCCell" bundle:nil] forCellWithReuseIdentifier:@"JFPenguinMinerGiftListCCell"];
}

+ (void)show
{
    JFPenguinMinerView *view = [[NSBundle mainBundle] loadNibNamed:@"JFPenguinMinerView" owner:self options:nil][0];
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
        [UINib nibWithNibName:@"JFPenguinMinerResultItemView" bundle:nil];
        
        view.isLuxury = NO;
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
- (IBAction)onClickNormalBtn:(id)sender
{
    self.isLuxury = NO;
    
    self.navSwitchBtn1.selected = YES;
    self.navSwitchBtn2.selected = NO;
}

- (IBAction)onClickLuxuryBtn:(id)sender
{
    self.isLuxury = YES;
    
    self.navSwitchBtn1.selected = NO;
    self.navSwitchBtn2.selected = YES;
}

/// 关闭视图
- (IBAction)onClickCloseBtn:(id)sender
{
    [self closeDialog];
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

// 点击
- (IBAction)onClickArrowBtn:(id)sender {
    if (self.collectionView.contentOffset.x + self.collectionView.bounds.size.width >= self.collectionView.contentSize.width) {
        [self.collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else {
        [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x + self.collectionView.bounds.size.width, 0) animated:YES];
    }
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
        // 弹出结果视图
        if (self.models) {
            [JFPenguinMinerResultView showWish:self.models];
            self.models = nil;
        }
    }
    
    [self stopAnimation];
}

#pragma mark - Network
- (void)openWishAction:(NSInteger)type
{
    if (self.isRequesting) {
        return;
    }
    self.isRequesting = YES;
    [self startAnimation];
    
    __weak typeof(self) weakSelf = self;
    [JFHttpRequestHelper wish:type success:^(id data) {
        
        weakSelf.isRequesting = NO;
        weakSelf.models = data;
        
    } failure:^(NSNumber *code, NSString *msg) {
        weakSelf.isRequesting = NO;
        [weakSelf stopAnimation];
        [MBProgressHUD showError:msg];
    }];
}

#pragma mark - <UICollectionViewDelegate && UICollectionViewDataSource && UICollectionViewDelegateFlowLayout>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.giftArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JFPenguinMinerGiftListCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JFPenguinMinerGiftListCCell" forIndexPath:indexPath];
    cell.model = [self.giftArray objectAtIndex:indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(77, 85);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 9;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - Network
- (void)getPenguinMinerGiftListData
{
    self.giftArray = [NSMutableArray array];
    __weak typeof(self)weakSelf = self;
    
    [JFHttpRequestHelper getWishListWithSuccess:^(id  _Nonnull data) {
        [weakSelf.giftArray appendObjects:[data copy]];
        [weakSelf.collectionView reloadData];
    } failure:^(NSNumber * _Nonnull code, NSString * _Nonnull msg) {
        [MBProgressHUD showError:msg];
    }];
}

#pragma mark - setter/getter
- (void)setIsLuxury:(BOOL)isLuxury
{
    _isLuxury = isLuxury;
    
    [self getPenguinMinerGiftListData];
    [self setupMaterial];
}

- (void)setupMaterial
{
    if (self.isLuxury) {
        self.priceLabel1.text = @"50";
        self.priceLabel2.text = @"500";
        self.priceLabel3.text = @"5000";
        
        self.bgImageView.image = [UIImage imageNamed:@"penguin_miner_open_bg_luxury"];
    } else {
        self.priceLabel1.text = @"20";
        self.priceLabel2.text = @"200";
        self.priceLabel3.text = @"2000";
        
        self.bgImageView.image = [UIImage imageNamed:@"penguin_miner_open_bg_normal"];
    }
}

@end
