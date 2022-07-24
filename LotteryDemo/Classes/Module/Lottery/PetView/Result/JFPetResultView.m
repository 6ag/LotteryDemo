//
//  JFPetResultView.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFPetResultView.h"
#import "JFPetResultCell.h"
#import "JFHttpRequestHelper.h"
#import <AudioToolbox/AudioToolbox.h>

@interface JFPetResultView ()<UICollectionViewDelegate,UICollectionViewDataSource>

// 多次许愿
@property (weak, nonatomic) IBOutlet UIView *moreResultView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *moreWishBtn20;
@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;

// 单次许愿
@property (weak, nonatomic) IBOutlet UIView *oneBgView;
@property (weak, nonatomic) IBOutlet UIImageView *oneBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *oneImageView;
@property (weak, nonatomic) IBOutlet UILabel *oneNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *onePriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *wishBtn1;

@property (strong,nonatomic) NSArray<JFLotteryResultItem *> *models;
@property (copy,nonatomic) JFRoomWishAgain buyBlock;
@property (copy,nonatomic) JFRoomWishClose closeBlock;

@property (assign,nonatomic) NSInteger againType;

@end

@implementation JFPetResultView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"JFPetResultCell" bundle:nil] forCellWithReuseIdentifier:@"JFPetResultCell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models againType:(NSInteger)againType buyBlock:(JFRoomWishAgain)buyBlock closeBlock:(JFRoomWishClose)closeBlock
{
    JFPetResultView *view = [[NSBundle mainBundle]loadNibNamed:@"JFPetResultView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

    view.buyBlock = buyBlock;
    view.closeBlock = closeBlock;
    view.againType = againType;
    view.models = models;
    
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view addNotification];
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
- (IBAction)sureBtnAction:(id)sender {
    [self closeDialog];
}

/// 再次许愿
- (IBAction)onceAgainAction:(UIButton *)sender {
    
    if (sender) {
        sender.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            sender.userInteractionEnabled = YES;
        });
    }
    
    [self onceAgain];
}

/// 重新喂食
- (void)onceAgain
{
    __weak typeof(self)weakSelf =self;
    [JFHttpRequestHelper wish:self.againType success:^(id data) {
        weakSelf.models = [data copy];
    } failure:^(NSNumber *code, NSString *msg) {
        [MBProgressHUD showError:msg];
    }];
}

#pragma mark - <UICollectionViewDelegate && UICollectionViewDataSource && UICollectionViewDelegateFlowLayout>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.models.count == 1) {
        return 0;
    }
    
    return self.models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JFPetResultCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JFPetResultCell" forIndexPath:indexPath];
    cell.model = [self.models objectAtIndex:indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((SCREEN_WIDTH - 35 * 2 - 10) / 4.0, (SCREEN_WIDTH - 35 * 2 - 10) / 4.0 + 35);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 5, 0, 5);
}

- (void)setModels:(NSArray<JFLotteryResultItem *> *)models
{
    _models = models;
    
    if (models.count == 1) {
        self.oneBgView.hidden = NO;
        self.moreResultView.hidden = YES;
        
        JFLotteryResultItem *item = models.firstObject;
        self.oneImageView.image = [UIImage imageNamed:item.picUrl];
        self.oneNameLabel.text = [NSString stringWithFormat:@"%@*%ld", item.itemName, item.num];
        self.onePriceLabel.text = [NSString stringWithFormat:@"%ld", item.goldPrice];
        
        if (item.goldPrice >= 30000) {
            self.oneBgImageView.image = [UIImage imageNamed:@"room_pet_result_gift_box_30k"];
        } else if (item.goldPrice >= 5000) {
            self.oneBgImageView.image = [UIImage imageNamed:@"room_pet_result_gift_box_5k"];
        } else {
            self.oneBgImageView.image = [UIImage imageNamed:@"room_pet_result_gift_box"];
        }
        
        [self startShakeAnimation];
    } else {
        self.oneBgView.hidden = YES;
        self.moreResultView.hidden = NO;
        
        [self.collectionView reloadData];
        
        [self stopShakeAnimation];
    }
    
    BOOL needShake = NO;
    for (JFLotteryResultItem *item in models) {
        if (item.goldPrice >= 5000) {
            needShake = YES;
        }
    }
    
    if (needShake) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (void)setAgainType:(NSInteger)againType
{
    _againType = againType;
    
    switch (againType) {
        case 1:
            [self.wishBtn1 setImage:[UIImage imageNamed:@"room_pet_result_one_1"] forState:UIControlStateNormal];
            [self.moreWishBtn20 setImage:[UIImage imageNamed:@"room_pet_result_more_1"] forState:UIControlStateNormal];
            break;
        case 2:
            [self.wishBtn1 setImage:[UIImage imageNamed:@"room_pet_result_one_10"] forState:UIControlStateNormal];
            [self.moreWishBtn20 setImage:[UIImage imageNamed:@"room_pet_result_more_10"] forState:UIControlStateNormal];
            break;
        case 3:
            [self.wishBtn1 setImage:[UIImage imageNamed:@"room_pet_result_one_20"] forState:UIControlStateNormal];
            [self.moreWishBtn20 setImage:[UIImage imageNamed:@"room_pet_result_more_20"] forState:UIControlStateNormal];
            break;
        case 4:
            [self.wishBtn1 setImage:[UIImage imageNamed:@"room_pet_result_one_50"] forState:UIControlStateNormal];
            [self.moreWishBtn20 setImage:[UIImage imageNamed:@"room_pet_result_more_50"] forState:UIControlStateNormal];
            break;
        case 5:
            [self.wishBtn1 setImage:[UIImage imageNamed:@"room_pet_result_one_100"] forState:UIControlStateNormal];
            [self.moreWishBtn20 setImage:[UIImage imageNamed:@"room_pet_result_more_100"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (void)startShakeAnimation
{
    CABasicAnimation *a1 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [a1 setFromValue:[NSNumber numberWithFloat:1.0]];
    [a1 setToValue:[NSNumber numberWithFloat:1.3]];
    [a1 setBeginTime:0.0];
    [a1 setDuration:0.1];
     
    CABasicAnimation *a2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [a2 setFromValue:[NSNumber numberWithFloat:1.3]];
    [a2 setToValue:[NSNumber numberWithFloat:0.8]];
    [a2 setBeginTime:0.1];
    [a2 setDuration:0.15];
    
    CABasicAnimation *a3 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [a3 setFromValue:[NSNumber numberWithFloat:0.8]];
    [a3 setToValue:[NSNumber numberWithFloat:1.0]];
    [a3 setBeginTime:0.25];
    [a3 setDuration:0.1];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    [group setDuration:0.35];
    [group setAnimations:[NSArray arrayWithObjects:a1, a2, a3, nil]];
     
    [self.oneImageView.layer addAnimation:group forKey:nil];
}

- (void)stopShakeAnimation
{
    [self.oneImageView.layer removeAllAnimations];
}

@end
