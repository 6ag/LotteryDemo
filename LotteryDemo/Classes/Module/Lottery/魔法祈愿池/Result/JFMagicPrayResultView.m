//
//  JFMagicPrayResultView.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFMagicPrayResultView.h"
#import "JFMagicPrayResultItemView.h"
#import <AudioToolbox/AudioToolbox.h>

@interface JFMagicPrayResultView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) JFRoomWishAgain againBlock;

@end

@implementation JFMagicPrayResultView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JFMagicPrayResultItemView" bundle:nil] forCellWithReuseIdentifier:@"JFMagicPrayResultItemView"];
}

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models againBlock:(JFRoomWishAgain)againBlock
{
    JFMagicPrayResultView *view = [[NSBundle mainBundle]loadNibNamed:@"JFMagicPrayResultView" owner:self options:nil][0];
    view.models = models;
    view.type = models.firstObject.againType;
    view.againBlock = againBlock;
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    view.contentView.alpha = 0;
    [UIView animateWithDuration:0.28 animations:^{
        view.contentView.alpha = 1;
    }];
}

#pragma mark - Event
- (IBAction)onTapCover:(id)sender
{
    [self removeFromSuperview];
}
- (IBAction)onClickAgainBtn:(id)sender
{
    if (self.againBlock) {
        self.againBlock(self.type);
    }
    [self onTapCover:nil];
}

#pragma mark - <UICollectionViewDelegate && UICollectionViewDataSource && UICollectionViewDelegateFlowLayout>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JFMagicPrayResultItemView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JFMagicPrayResultItemView" forIndexPath:indexPath];
    cell.model = [self.models objectAtIndex:indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = (kScreenWidth - 100 - 15 * 2) / 3.0;
    return CGSizeMake(floor(itemWidth), itemWidth + 30);
}

// 滚动方向的item间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 12;
}

// 滚动方向的交叉方向的item间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 15;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(8, 0, 0, 0);
}

#pragma mark - setter/getter
- (void)setModels:(NSArray<JFLotteryResultItem *> *)models
{
    _models = models;

    NSInteger totalPrice = 0;
    BOOL needShake = NO;
    for (JFLotteryResultItem *item in models) {
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
    self.totalPriceLabel.text = [NSString stringWithFormat:@"礼物总值: %ld", totalPrice];
    
    [self.collectionView reloadData];
}

@end
