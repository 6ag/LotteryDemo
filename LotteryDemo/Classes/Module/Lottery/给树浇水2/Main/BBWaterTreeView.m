//
//  BBWaterTreeView.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/26.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "BBWaterTreeView.h"
#import "JFNoHighlightButton.h"
#import "JFHttpRequestHelper.h"
#import "BBWaterTreeResultView.h"
#import "BBWaterTreeGiftListCCell.h"
#import <SVGAParser.h>
#import <SVGAImageView.h>
#import "SVGAVideoEntity.h"

#define CONTENT_VIEW_HEIGHT (kScreenWidth/(375.0/500.0))

@interface BBWaterTreeView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SVGAPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *levelBtn0;
@property (weak, nonatomic) IBOutlet UIButton *levelBtn1;

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet SVGAImageView *normalSvgaView;
@property (weak, nonatomic) IBOutlet SVGAImageView *openSvgaView;
@property (weak, nonatomic) IBOutlet SVGAImageView *lightSvgaView;
@property (weak, nonatomic) IBOutlet SVGAImageView *fertilizeSvgaView;

@property (weak, nonatomic) IBOutlet UIButton *animBtn;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray<JFLotteryResultItem *> *giftArray;

@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;

@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *optionBtn1;
@property (weak, nonatomic) IBOutlet UIButton *optionBtn2;
@property (weak, nonatomic) IBOutlet UIButton *optionBtn3;
@property (nonatomic, assign) NSInteger type;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_contentView;

@property (nonatomic, assign) BOOL isAnimation;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, assign) NSInteger level;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@end

@implementation BBWaterTreeView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BBWaterTreeGiftListCCell" bundle:nil] forCellWithReuseIdentifier:@"BBWaterTreeGiftListCCell"];
    
    [self onClickOptionBtn1:nil];
    self.openSvgaView.delegate = self;
    self.fertilizeSvgaView.delegate = self;
}

+ (void)show
{
    BBWaterTreeView *view = [[NSBundle mainBundle] loadNibNamed:@"BBWaterTreeView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    view.animBtn.selected = [[NSUserDefaults standardUserDefaults] boolForKey:@"TWISTEDEGG_ANIM_STATUS"];

    view.coverView.alpha = 0;
    view.bottom_contentView.constant = -CONTENT_VIEW_HEIGHT;
    
    [view layoutIfNeeded];
    [UIView animateWithDuration:0.28 animations:^{
        view.coverView.alpha = 1;
        view.bottom_contentView.constant = (iPhoneX ? 0 : -20);
        [view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [view onClickLevelBtn1:nil];
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
    // 最多显示8个
    return MIN(8, self.giftArray.count);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BBWaterTreeGiftListCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BBWaterTreeGiftListCCell" forIndexPath:indexPath];
    cell.model = [self.giftArray objectAtIndex:indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(48, 70);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return SCREEN_WIDTH - 18 * 2 - 48 * 2;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
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
}

- (IBAction)onClickLevelBtn1:(id)sender
{
    if (self.level == 1) {
        return;
    }
    self.level = 1;
    
    self.levelBtn0.selected = NO;
    self.levelBtn1.selected = YES;
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

/// 动画开关
- (IBAction)onClickAnimBtn:(id)sender
{
    self.animBtn.selected = !self.animBtn.selected;
    [[NSUserDefaults standardUserDefaults] setBool:self.animBtn.selected forKey:@"TWISTEDEGG_ANIM_STATUS"];
}

// 1次
- (IBAction)onClickOptionBtn1:(id)sender {
    if (self.type == 1) {
        return;
    }
    self.type = 1;
    
    self.optionBtn1.selected = YES;
    self.optionBtn2.selected = NO;
    self.optionBtn3.selected = NO;
    [self.startBtn setImage:[UIImage imageNamed:@"bb_water_tree_open_start_1"] forState:UIControlStateNormal];
}

// 10次
- (IBAction)onClickOptionBtn2:(id)sender {
    if (self.type == 2) {
        return;
    }
    self.type = 2;
    
    self.optionBtn1.selected = NO;
    self.optionBtn2.selected = YES;
    self.optionBtn3.selected = NO;
    [self.startBtn setImage:[UIImage imageNamed:@"bb_water_tree_open_start_10"] forState:UIControlStateNormal];
}

// 100次
- (IBAction)onClickOptionBtn3:(id)sender {
    if (self.type == 5) {
        return;
    }
    self.type = 5;
    
    self.optionBtn1.selected = NO;
    self.optionBtn2.selected = NO;
    self.optionBtn3.selected = YES;
    [self.startBtn setImage:[UIImage imageNamed:@"bb_water_tree_open_start_100"] forState:UIControlStateNormal];
}

- (IBAction)onClickStartBtn:(id)sender {
    [self openWishAction:self.type];
}

- (void)setCountBtnUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    self.optionBtn1.userInteractionEnabled = userInteractionEnabled;
    self.optionBtn2.userInteractionEnabled = userInteractionEnabled;
    self.optionBtn3.userInteractionEnabled = userInteractionEnabled;
    self.startBtn.userInteractionEnabled = userInteractionEnabled;
    self.animBtn.userInteractionEnabled = userInteractionEnabled;
}

#pragma mark - SVGAPlayerDelegate
- (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player
{
    if (player == self.fertilizeSvgaView) {
        self.fertilizeSvgaView.hidden = YES;
        self.normalSvgaView.hidden = YES;
        
        self.openSvgaView.hidden = NO;
        [self.openSvgaView stepToFrame:0 andPlay:NO];
        [self.openSvgaView startAnimation];
    } else if (player == self.openSvgaView) {
        self.normalSvgaView.hidden = NO;
        self.openSvgaView.hidden = YES;
        [self showResultView];
    }
}

/// 播放施肥动画
- (void)startPlayFertilizeAnim
{
    self.fertilizeSvgaView.hidden = NO;
    [self.fertilizeSvgaView stepToFrame:0 andPlay:NO];
    [self.fertilizeSvgaView startAnimation];
}

#pragma mark - Network
- (void)openWishAction:(NSInteger)type
{
    if (self.isRequesting) {
        return;
    }
    self.isRequesting = YES;
    [self setCountBtnUserInteractionEnabled:NO];
    if (!self.animBtn.selected) {
        [self startPlayFertilizeAnim];
    }
    
    __weak typeof(self) weakSelf = self;
    [JFHttpRequestHelper wish:type success:^(id data) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.isRequesting = NO;
            weakSelf.models = data;
            
            if (weakSelf.animBtn.selected) {
                [weakSelf showResultView];
            }
        });
    } failure:^(NSNumber *code, NSString *msg) {
        weakSelf.isRequesting = NO;
        [weakSelf setCountBtnUserInteractionEnabled:YES];
        [MBProgressHUD showError:msg];
    }];
}

/// 弹出结果视图
- (void)showResultView
{
    if (self.models) {
        __weak typeof(self) weakSelf = self;
        [BBWaterTreeResultView showWish:self.models callback:^{
            [weakSelf setCountBtnUserInteractionEnabled:YES];
        }];
        self.models = nil;
    }
}

- (void)getWaterTreeGiftListData
{
    self.giftArray = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    [JFHttpRequestHelper getWishListWithSuccess:^(id  _Nonnull data) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.giftArray appendObjects:[data copy]];
            [weakSelf.collectionView reloadData];
        });
    } failure:^(NSNumber * _Nonnull code, NSString * _Nonnull msg) {
        [MBProgressHUD showError:msg];
    }];
}

#pragma mark - setter/getter
- (void)setLevel:(NSInteger)level
{
    _level = level;
    
    [self setupMaterial];
    [self getWaterTreeGiftListData];
}

- (void)setupMaterial
{
    switch (self.level) {
        case 0: {
            [self.optionBtn1 setBackgroundImage:[UIImage imageNamed:@"bb_water_tree_open_count_1_level0"] forState:UIControlStateNormal];
            [self.optionBtn2 setBackgroundImage:[UIImage imageNamed:@"bb_water_tree_open_count_10_level0"] forState:UIControlStateNormal];
            [self.optionBtn3 setBackgroundImage:[UIImage imageNamed:@"bb_water_tree_open_count_100_level0"] forState:UIControlStateNormal];
            
            [self.optionBtn1 setBackgroundImage:[UIImage imageNamed:@"bb_water_tree_open_count_1_sel_level0"] forState:UIControlStateSelected];
            [self.optionBtn2 setBackgroundImage:[UIImage imageNamed:@"bb_water_tree_open_count_10_sel_level0"] forState:UIControlStateSelected];
            [self.optionBtn3 setBackgroundImage:[UIImage imageNamed:@"bb_water_tree_open_count_100_sel_level0"] forState:UIControlStateSelected];
            
            self.lightSvgaView.hidden = YES;
        }
            break;
        case 1: {
            [self.optionBtn1 setBackgroundImage:[UIImage imageNamed:@"bb_water_tree_open_count_1_level1"] forState:UIControlStateNormal];
            [self.optionBtn2 setBackgroundImage:[UIImage imageNamed:@"bb_water_tree_open_count_10_level1"] forState:UIControlStateNormal];
            [self.optionBtn3 setBackgroundImage:[UIImage imageNamed:@"bb_water_tree_open_count_100_level1"] forState:UIControlStateNormal];
            
            [self.optionBtn1 setBackgroundImage:[UIImage imageNamed:@"bb_water_tree_open_count_1_sel_level1"] forState:UIControlStateSelected];
            [self.optionBtn2 setBackgroundImage:[UIImage imageNamed:@"bb_water_tree_open_count_10_sel_level1"] forState:UIControlStateSelected];
            [self.optionBtn3 setBackgroundImage:[UIImage imageNamed:@"bb_water_tree_open_count_100_sel_level1"] forState:UIControlStateSelected];
            
            self.lightSvgaView.hidden = NO;
        }
            break;
        default:
            break;
    }
}

@end
