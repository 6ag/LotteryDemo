//
//  JFOrchardResultView.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFOrchardResultView.h"
#import "JFOrchardResultItemView.h"
#import <AudioToolbox/AudioToolbox.h>

@interface JFOrchardResultView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) JFRoomWishAgain againBlock;

@end

@implementation JFOrchardResultView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"JFOrchardResultItemView" bundle:nil] forCellWithReuseIdentifier:@"JFOrchardResultItemView"];
}

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models type:(NSInteger)type againBlock:(JFRoomWishAgain)againBlock
{
    JFOrchardResultView *view = [[NSBundle mainBundle] loadNibNamed:@"JFOrchardResultView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    view.models = models;
    view.type = type;
    view.againBlock = againBlock;
    
    view.alpha = 0;
    [UIView animateWithDuration:0.28 animations:^{
        view.alpha = 1;
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
    JFOrchardResultItemView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JFOrchardResultItemView" forIndexPath:indexPath];
    cell.model = [self.models objectAtIndex:indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = (kScreenWidth - 110 - 14 * 2) / 3.0;
    return CGSizeMake(floor(itemWidth), itemWidth + 30);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 14;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - setter/getter
- (void)setModels:(NSArray<JFLotteryResultItem *> *)models
{
    _models = models;

    NSInteger totalPrice = 0;
    BOOL needShake = NO;
    for (JFLotteryResultItem *item in models) {
        if (item.goldPrice >= 5000) {
            needShake = YES;
        }
        
        totalPrice += item.goldPrice * item.num;
    }
    
    if (needShake) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    self.totalPriceLabel.text = [NSString stringWithFormat:@"总价值: %ld", totalPrice];
    
    [self.collectionView reloadData];
}

@end
