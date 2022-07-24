//
//  JFIdolProjectResultView.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFIdolProjectResultView.h"
#import "JFIdolProjectResultCell.h"

@interface JFIdolProjectResultView ()<UICollectionViewDelegate, UICollectionViewDataSource>

//多次许愿
@property (weak, nonatomic) IBOutlet UIView *moreResultView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *moreSureBtn;
@property (weak, nonatomic) IBOutlet UIButton *moreWishBtn20;

//单次许愿
@property (weak, nonatomic) IBOutlet UIView *oneBgView;
@property (weak, nonatomic) IBOutlet UIImageView *oneImageView;
@property (weak, nonatomic) IBOutlet UILabel *oneLabel;
@property (weak, nonatomic) IBOutlet UIButton *wishBtn1;

@property (strong,nonatomic) NSArray<JFLotteryResultItem *> *models;
@property (copy,nonatomic) JFRoomWishAgain buyBlock;

@property (assign,nonatomic) NSInteger againType;

@end

@implementation JFIdolProjectResultView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"JFIdolProjectResultCell" bundle:nil] forCellWithReuseIdentifier:@"JFIdolProjectResultCell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models againType:(NSInteger)againType buyBlock:(JFRoomWishAgain)buyBlock
{
    JFIdolProjectResultView *shareView = [[NSBundle mainBundle]loadNibNamed:@"JFIdolProjectResultView" owner:self options:nil][0];
    shareView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    shareView.buyBlock = buyBlock;
    
    [[UIApplication sharedApplication].keyWindow addSubview:shareView];
    [shareView addNotification];
    
    shareView.againType = againType;
    shareView.models = models;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sureBtnAction:) name:@"CloseRoomDialogView" object:nil];
}

- (IBAction)sureBtnAction:(id)sender {
    [self removeFromSuperview];
}

//单次许愿
- (IBAction)oneWishBtnAction:(UIButton *)sender {
    
    if (sender) {
        sender.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            sender.userInteractionEnabled = YES;
        });
    }
    
    [MBProgressHUD showLoading];
    __weak typeof(self)weakSelf =self;
    [JFHttpRequestHelper wish:self.againType success:^(id data) {
        
        [MBProgressHUD hideHUD];
        weakSelf.models = data;
        
    } failure:^(NSNumber *code, NSString *msg) {
        [MBProgressHUD showError:msg];
        [weakSelf sureBtnAction:nil];
        if (weakSelf.buyBlock) weakSelf.buyBlock(self.againType);
    }];
    
    
    
}

- (IBAction)wishBtnAction10:(UIButton *)sender {
    
    if (sender) {
        sender.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            sender.userInteractionEnabled = YES;
        });
    }
    
    [MBProgressHUD showLoading];
    __weak typeof(self)weakSelf =self;
    [JFHttpRequestHelper wish:self.againType success:^(id data) {
        
        [MBProgressHUD hideHUD];
        weakSelf.models = data;
        
    } failure:^(NSNumber *code, NSString *msg) {
        [MBProgressHUD showError:msg];
        [weakSelf sureBtnAction:nil];
        if (weakSelf.buyBlock) weakSelf.buyBlock(self.againType);
    }];
    
}

- (IBAction)wishBtnAction20:(UIButton *)sender {
    
    if (sender) {
        sender.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            sender.userInteractionEnabled = YES;
        });
    }
    
    if (self.againType == 1) {
        [self oneWishBtnAction:nil];
        return;
    }
    
    if (self.againType == 2) {
        [self wishBtnAction10:nil];
        return;
    }
    
    [MBProgressHUD showLoading];
    __weak typeof(self)weakSelf =self;
    [JFHttpRequestHelper wish:self.againType success:^(id data) {
        
        [MBProgressHUD hideHUD];
        weakSelf.models = data;
        
    } failure:^(NSNumber *code, NSString *msg) {
        [MBProgressHUD showError:msg];
        [weakSelf sureBtnAction:nil];
        if (weakSelf.buyBlock) weakSelf.buyBlock(self.againType);
    }];

}

- (IBAction)oneSureAction:(id)sender {
    [self removeFromSuperview];
}

#pragma mark - <UICollectionViewDelegate && UICollectionViewDataSource && UICollectionViewDelegateFlowLayout>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.models.count == 1) {
        return 0;
    }
    
    return self.models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JFIdolProjectResultCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JFIdolProjectResultCell" forIndexPath:indexPath];
    
    JFLotteryResultItem *model = [self.models objectAtIndex:indexPath.item];
    cell.model = model;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 118);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)setModels:(NSArray<JFLotteryResultItem *> *)models
{
    _models = models;
    
    if (models.count == 1) {
        self.moreResultView.hidden = YES;
        self.moreSureBtn.hidden = YES;
        self.moreWishBtn20.hidden = YES;
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
        self.moreSureBtn.hidden = NO;
        self.moreWishBtn20.hidden = NO;
        [self.collectionView reloadData];
        
        [self stopShakeAnimation];
    }
}

- (void)setAgainType:(NSInteger)againType
{
    _againType = againType;
    if (againType == 1) {
        [self.moreWishBtn20 setImage:[UIImage imageNamed:@"prize_award_open1"] forState:UIControlStateNormal];
    } else if (againType == 2) {
        [self.moreWishBtn20 setImage:[UIImage imageNamed:@"prize_award_open10"] forState:UIControlStateNormal];
    } else if (againType == 3) {
        [self.moreWishBtn20 setImage:[UIImage imageNamed:@"prize_award_open20"] forState:UIControlStateNormal];
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
