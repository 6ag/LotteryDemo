//
//  BBTreasureBoxView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "BBTreasureBoxView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "BBTreasureBoxResultView.h"
#import <SVGAParser.h>
#import <SVGAImageView.h>
#import "SVGAVideoEntity.h"
#import "BBTreasureBoxGiftListCCell.h"

#define CONTENT_VIEW_HEIGHT (kScreenWidth/(375.0/560.0))

@interface BBTreasureBoxView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIButton *levelBtn0;
@property (weak, nonatomic) IBOutlet UIButton *levelBtn1;
@property (weak, nonatomic) IBOutlet UIButton *levelBtn2;

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *boxBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *boxBottomImageView;
@property (weak, nonatomic) IBOutlet UIImageView *boxCirclemImageView;
@property (weak, nonatomic) IBOutlet UIImageView *boxImageView;
@property (weak, nonatomic) IBOutlet UIImageView *boxFd1ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *boxFd2ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *boxFd3ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *boxFd4ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *boxFd5ImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height_giftView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray<JFLotteryResultItem *> *giftArray;

@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;

@property (weak, nonatomic) IBOutlet UIButton *optionBtn1;
@property (weak, nonatomic) IBOutlet UIButton *optionBtn2;
@property (weak, nonatomic) IBOutlet UIButton *optionBtn3;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_contentView;

@property (nonatomic, assign) BOOL isAnimation;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, assign) NSInteger level;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@end

@implementation BBTreasureBoxView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BBTreasureBoxGiftListCCell" bundle:nil] forCellWithReuseIdentifier:@"BBTreasureBoxGiftListCCell"];
}

+ (void)show
{
    BBTreasureBoxView *view = [[NSBundle mainBundle] loadNibNamed:@"BBTreasureBoxView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];

    view.coverView.alpha = 0;
    view.bottom_contentView.constant = -CONTENT_VIEW_HEIGHT;
    view.height_giftView.constant = (kScreenWidth - 7 * 2) / 4 - 8 * 2 + 14 + 20;
    
    [view layoutIfNeeded];
    [UIView animateWithDuration:0.28 animations:^{
        view.coverView.alpha = 1;
        view.bottom_contentView.constant = (iPhoneX ? 0 : -20);
        [view layoutIfNeeded];
    } completion:^(BOOL finished) {
        // 先从xib里加载一次结果单项视图，这样弹窗避免卡顿
        [UINib nibWithNibName:@"BBTreasureBoxResultItemView" bundle:nil];
        
        view.level = 0;
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

#pragma mark - <UICollectionViewDelegate && UICollectionViewDataSource && UICollectionViewDelegateFlowLayout>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.giftArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BBTreasureBoxGiftListCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BBTreasureBoxGiftListCCell" forIndexPath:indexPath];
    cell.model = [self.giftArray objectAtIndex:indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = (kScreenWidth - 7 * 2) / 4;
    CGFloat itemHeight = (kScreenWidth - 7 * 2) / 4 - 8 * 2 + 14 + 20;
    return CGSizeMake(itemWidth, itemHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 7, 0, 7);
}

#pragma mark - Event
- (IBAction)onClickLevelBtn0:(id)sender
{
    if (self.level == 0) {
        return;
    }
    self.level = 0;
    
    self.levelBtn0.selected = YES;
    self.levelBtn1.selected = NO;
    self.levelBtn2.selected = NO;
}

- (IBAction)onClickLevelBtn1:(id)sender
{
    if (self.level == 1) {
        return;
    }
    self.level = 1;
    
    self.levelBtn0.selected = NO;
    self.levelBtn1.selected = YES;
    self.levelBtn2.selected = NO;
}

- (IBAction)onClickLevelBtn2:(id)sender
{
    if (self.level == 2) {
        return;
    }
    self.level = 2;
    
    self.levelBtn0.selected = NO;
    self.levelBtn1.selected = NO;
    self.levelBtn2.selected = YES;
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

/// 金豆充值
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

#pragma mark - Network
- (void)openWishAction:(NSInteger)type
{
    if (self.isRequesting) {
        return;
    }
    self.isRequesting = YES;
    [self setCountBtnUserInteractionEnabled:NO];
    
    __weak typeof(self) weakSelf = self;
    [JFHttpRequestHelper wish:type success:^(id data) {
        
        weakSelf.isRequesting = NO;
        weakSelf.models = data;
        [weakSelf showResultView];
        
    } failure:^(NSNumber *code, NSString *msg) {
        weakSelf.isRequesting = NO;
        [weakSelf setCountBtnUserInteractionEnabled:YES];
        [MBProgressHUD showError:msg];
    }];
}

- (void)showResultView
{
    // 弹出结果视图
    if (self.models) {
        __weak typeof(self) weakSelf = self;
        [BBTreasureBoxResultView showWish:self.models callback:^{
            [weakSelf setCountBtnUserInteractionEnabled:YES];
        }];
        self.models = nil;
    }
}

- (void)getTreasureBoxGiftListData
{
    self.giftArray = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    [JFHttpRequestHelper getWishListWithSuccess:^(id  _Nonnull data) {
        [weakSelf.giftArray appendObjects:[data copy]];
        [weakSelf.collectionView reloadData];
    } failure:^(NSNumber * _Nonnull code, NSString * _Nonnull msg) {
        [MBProgressHUD showError:msg];
    }];
}

#pragma mark - setter/getter
- (void)setLevel:(NSInteger)level
{
    _level = level;
    
    [self setupMaterial];
    [self getTreasureBoxGiftListData];
}

- (void)setupMaterial
{
    switch (self.level) {
        case 0: {
            self.boxImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_level0"];
            self.boxBgImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_bg_level0"];
            self.boxBottomImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_bottom_level0"];
            self.boxCirclemImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_circle_level0"];
            self.boxFd1ImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_fd1_level0"];
            self.boxFd2ImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_fd1_level0"];
            self.boxFd3ImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_fd3_level0"];
            self.boxFd4ImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_fd4_level0"];
            self.boxFd5ImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_fd5_level0"];
            
            [self.optionBtn1 setImage:[UIImage imageNamed:@"bb_treasure_box_open_count_1_level0"] forState:UIControlStateNormal];
            [self.optionBtn2 setImage:[UIImage imageNamed:@"bb_treasure_box_open_count_10_level0"] forState:UIControlStateNormal];
            [self.optionBtn3 setImage:[UIImage imageNamed:@"bb_treasure_box_open_count_100_level0"] forState:UIControlStateNormal];
        }
            break;
        case 1: {
            self.boxImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_level1"];
            self.boxBgImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_bg_level1"];
            self.boxBottomImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_bottom_level1"];
            self.boxCirclemImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_circle_level1"];
            self.boxFd1ImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_fd1_level1"];
            self.boxFd2ImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_fd1_level1"];
            self.boxFd3ImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_fd3_level1"];
            self.boxFd4ImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_fd4_level1"];
            self.boxFd5ImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_fd5_level1"];
            
            [self.optionBtn1 setImage:[UIImage imageNamed:@"bb_treasure_box_open_count_1_level1"] forState:UIControlStateNormal];
            [self.optionBtn2 setImage:[UIImage imageNamed:@"bb_treasure_box_open_count_10_level1"] forState:UIControlStateNormal];
            [self.optionBtn3 setImage:[UIImage imageNamed:@"bb_treasure_box_open_count_100_level1"] forState:UIControlStateNormal];
        }
            break;
        case 2: {
            self.boxImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_level2"];
            self.boxBgImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_bg_level2"];
            self.boxBottomImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_bottom_level2"];
            self.boxCirclemImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_circle_level2"];
            self.boxFd1ImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_fd1_level2"];
            self.boxFd2ImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_fd1_level2"];
            self.boxFd3ImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_fd3_level2"];
            self.boxFd4ImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_fd4_level2"];
            self.boxFd5ImageView.image = [UIImage imageNamed:@"bb_treasure_box_open_box_fd5_level2"];
            
            [self.optionBtn1 setImage:[UIImage imageNamed:@"bb_treasure_box_open_count_1_level2"] forState:UIControlStateNormal];
            [self.optionBtn2 setImage:[UIImage imageNamed:@"bb_treasure_box_open_count_10_level2"] forState:UIControlStateNormal];
            [self.optionBtn3 setImage:[UIImage imageNamed:@"bb_treasure_box_open_count_100_level2"] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

@end
