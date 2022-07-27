//
//  JFDragonSlayerResultView.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFDragonSlayerResultView.h"
#import "JFDragonSlayerResultItemView.h"
#import "JFHttpRequestHelper.h"
#import <AudioToolbox/AudioToolbox.h>
#import "JFDragonSlayerBigResultView.h"

@interface JFDragonSlayerResultView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *itemsView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@end

@implementation JFDragonSlayerResultView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models
{
    JFDragonSlayerResultView *view = [[NSBundle mainBundle]loadNibNamed:@"JFDragonSlayerResultView" owner:self options:nil][0];
    view.models = models;
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    view.alpha = 0;
    
    NSInteger bigCount = 0;
    for (JFLotteryResultItem *item in models) {
        if (item.goldPrice >= 3344) {
            bigCount++;
        }
    }
    if (bigCount > 0) {
        [JFDragonSlayerBigResultView showWish:models];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.28 animations:^{
                view.alpha = 1;
            }];
        });
        
    } else {
        [UIView animateWithDuration:0.28 animations:^{
            view.alpha = 1;
        }];
    }
}

#pragma mark - Event
- (IBAction)onTapCover:(id)sender
{
    [self removeFromSuperview];
}

/// 展开itemView
/// @param itemViewList 视图集合
- (void)expandItemViewsWithItemViewList:(NSMutableArray<JFDragonSlayerResultItemView *> *)itemViewList
{
    [self layoutIfNeeded];
    
    NSInteger colCount = 3;
    CGFloat itemWidth = (kScreenWidth - 78) / 3;
    CGFloat itemHeight = 125;
    
    for (int i = 0; i < itemViewList.count; i++) {
        JFDragonSlayerResultItemView *itemView = itemViewList[i];
        itemView.frame = CGRectMake(0, 0, itemWidth, itemHeight);
        itemView.center = CGPointMake((kScreenWidth - 40) * 0.5, self.itemsView.height * 0.5);
        itemView.alpha = 0;
        
        [self.itemsView addSubview:itemView];
    }
    
    [UIView animateWithDuration:0.28 animations:^{
        for (int i = 0; i < itemViewList.count; i++) {
            JFDragonSlayerResultItemView *itemView = itemViewList[i];
            
            NSInteger row = i / colCount;
            NSInteger col = i % colCount;
            CGFloat margin = ((kScreenWidth - 40) - (itemWidth * colCount)) / (colCount + 1);
            CGFloat x = margin + (itemWidth + margin) * col;
            CGFloat y = itemHeight * row;
            
            itemView.frame = CGRectMake(x, y, itemWidth, itemHeight);
            
            itemView.alpha = 1;
        }
    }];
    
}

#pragma mark - setter/getter
- (void)setModels:(NSArray<JFLotteryResultItem *> *)models
{
    _models = models;
    
    UINib *itemViewNib = [UINib nibWithNibName:@"JFDragonSlayerResultItemView" bundle:nil];
    NSMutableArray<JFDragonSlayerResultItemView *> *itemViewList = [NSMutableArray array];
    NSInteger totalPrice = 0;
    
    NSInteger bigCount = 0;
    BOOL needShake = NO;
    for (JFLotteryResultItem *item in models) {
        if (item.goldPrice >= 5000) {
            needShake = YES;
        }
        
        totalPrice += item.goldPrice * item.num;
        JFDragonSlayerResultItemView *itemView = [itemViewNib instantiateWithOwner:nil options:nil].firstObject;
        itemView.model = item;
        [itemViewList addObject:itemView];
        
        if (item.goldPrice >= 2000) {
            bigCount++;
        }
    }
    
    if (needShake) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    self.totalPriceLabel.text = [NSString stringWithFormat:@"礼物总值:%ld", totalPrice];
    [self expandItemViewsWithItemViewList:itemViewList];
}

@end
