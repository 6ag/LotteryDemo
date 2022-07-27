//
//  JFMagicTableResultView.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFMagicTableResultView.h"
#import "JFMagicTableResultCell.h"
#import "JFHttpRequestHelper.h"
#import "JFMagicTableView.h"

@interface JFMagicTableResultView ()<UICollectionViewDelegate,UICollectionViewDataSource>

//多次许愿
@property (weak, nonatomic) IBOutlet UIView *moreResultView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *moreSureBtn;
@property (weak, nonatomic) IBOutlet UIButton *moreWishBtn10;
@property (weak, nonatomic) IBOutlet UIButton *moreWishBtn20;

//单次许愿
@property (weak, nonatomic) IBOutlet UIView *oneBgView;
@property (weak, nonatomic) IBOutlet UIImageView *oneImageView;
@property (weak, nonatomic) IBOutlet UILabel *oneLabel;
@property (weak, nonatomic) IBOutlet UIButton *oneWishBtn1;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;
@property (copy,nonatomic) JFRoomWishAgain buyBlock;

@end

@implementation JFMagicTableResultView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"JFMagicTableResultCell" bundle:nil] forCellWithReuseIdentifier:@"JFMagicTableResultCell"];
}

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models buyBlock:(JFRoomWishAgain)buyBlock
{
    JFMagicTableResultView *view = [[NSBundle mainBundle]loadNibNamed:@"JFMagicTableResultView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    view.buyBlock = buyBlock;
    view.models = models;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sureBtnAction:) name:@"CloseRoomDialogView" object:nil];
}

#pragma mark - Event
- (IBAction)sureBtnAction:(id)sender {
    [self removeFromSuperview];
}

// 单次许愿
- (IBAction)oneWishBtnAction:(UIButton *)sender {
    
    if (sender) {
        sender.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            sender.userInteractionEnabled = YES;
        });
    }
    
    [self openWish:1];
}

- (IBAction)wishBtnAction10:(UIButton *)sender {
    
    if (sender) {
        sender.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            sender.userInteractionEnabled = YES;
        });
    }
    
    [self openWish:2];
}

- (IBAction)wishBtnAction20:(UIButton *)sender {
    
    if (sender) {
        sender.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            sender.userInteractionEnabled = YES;
        });
    }
    
    [self openWish:3];
}

- (void)openWish:(NSInteger)type
{
    __weak typeof(self) weakSelf = self;
    [JFHttpRequestHelper wish:type success:^(id data) {
        weakSelf.models = [data copy];
    } failure:^(NSNumber *code, NSString *msg) {
        [MBProgressHUD showError:msg];
    }];
}

#pragma mark - UICollectionViewDelegate && UICollectionViewDataSource && UICollectionViewDelegateFlowLayout
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.models.count == 1) {
        return 0;
    }
    
    return self.models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JFMagicTableResultCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JFMagicTableResultCell" forIndexPath:indexPath];
    cell.model = [self.models objectAtIndex:indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((kScreenWidth - 48 * 2 - 20) / 3.0, (kScreenWidth - 48 * 2 - 20) / 3.0 + 29);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - Animation
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

#pragma mark - setter/getter
- (void)setModels:(NSArray<JFLotteryResultItem *> *)models
{
    _models = models;
    
    if (models.count == 1) {
        self.moreResultView.hidden = YES;
        self.oneBgView.hidden = NO;

        self.oneImageView.image = nil;
        self.oneLabel.text = @"";
        
        JFLotteryResultItem *item = models.firstObject;
        self.oneImageView.image = [UIImage imageNamed:item.picUrl];
        self.oneLabel.text = [NSString stringWithFormat:@"%@*%ld", item.itemName, item.num];
        
        [self startShakeAnimation];
    } else {
        self.oneBgView.hidden = YES;
        self.moreResultView.hidden = NO;
        [self.collectionView reloadData];
        
        [self stopShakeAnimation];
    }
}

@end
