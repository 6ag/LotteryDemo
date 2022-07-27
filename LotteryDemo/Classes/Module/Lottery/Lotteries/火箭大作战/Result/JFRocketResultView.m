//
//  JFRocketResultView.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFRocketResultView.h"
#import "JFRocketResultItemView.h"
#import "JFHttpRequestHelper.h"
#import <AudioToolbox/AudioToolbox.h>

@interface JFRocketResultView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) JFRocketResultAgainBlock againBlock;

@end

@implementation JFRocketResultView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"JFRocketResultItemView" bundle:nil] forCellWithReuseIdentifier:@"JFRocketResultItemView"];
}

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models type:(NSInteger)type againBlock:(JFRocketResultAgainBlock)againBlock
{
    JFRocketResultView *view = [[NSBundle mainBundle] loadNibNamed:@"JFRocketResultView" owner:self options:nil][0];
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
    JFRocketResultItemView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JFRocketResultItemView" forIndexPath:indexPath];
    cell.model = [self.models objectAtIndex:indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = (kScreenWidth - 80 - 15 * 3) / 4.0;
    return CGSizeMake(floor(itemWidth), itemWidth + 50);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 15;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - setter/getter
- (void)setModels:(NSMutableArray<JFLotteryResultItem *> *)models
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
    self.totalPriceLabel.text = [NSString stringWithFormat:@"礼物总值: %ld", totalPrice];
    
    [self.collectionView reloadData];
}

@end
