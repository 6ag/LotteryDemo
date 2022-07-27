//
//  BBTurntableResultView.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "BBTurntableResultView.h"
#import "BBTurntableResultItemView.h"
#import "JFHttpRequestHelper.h"
#import <AudioToolbox/AudioToolbox.h>
#import "BBTurntableBigPriceResultView.h"

@interface BBTurntableResultView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *itemsView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@end

@implementation BBTurntableResultView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models
{
    BBTurntableResultView *view = [[NSBundle mainBundle] loadNibNamed:@"BBTurntableResultView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    view.models = models;
    
    view.alpha = 0;
    [UIView animateWithDuration:0.28 animations:^{
        view.alpha = 1;
    } completion:^(BOOL finished) {
        
        JFLotteryResultItem *surpriseItem = nil;
        for (JFLotteryResultItem *item in models) {
            if (item.goldPrice >= 2000) {
                surpriseItem = item;
            }
        }
        
        if (surpriseItem) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [BBTurntableBigPriceResultView showBigPriceWish:surpriseItem];
            });
        }
        
    }];
}

#pragma mark - Event
- (IBAction)onTapCover:(id)sender
{
    [self removeFromSuperview];
}

/// 展开itemView
/// @param itemViewList 视图集合
- (void)expandItemViewsWithItemViewList:(NSMutableArray<BBTurntableResultItemView *> *)itemViewList
{
    [self layoutIfNeeded];
    
    CGSize itemsViewSize = self.itemsView.bounds.size;
    NSInteger colCount = 3;
    CGFloat itemWidth = 85;
    CGFloat itemHeight = 120;
    
    for (int i = 0; i < itemViewList.count; i++) {
        BBTurntableResultItemView *itemView = itemViewList[i];
        itemView.frame = CGRectMake(0, 0, itemWidth, itemHeight);
        itemView.center = CGPointMake(itemsViewSize.width * 0.5, itemsViewSize.height * 0.5);
        itemView.alpha = 0;
        
        [self.itemsView addSubview:itemView];
    }
    
    // 礼物从中间展开的动画
    [UIView animateWithDuration:0.28 animations:^{
        for (int i = 0; i < itemViewList.count; i++) {
            BBTurntableResultItemView *itemView = itemViewList[i];
            
            NSInteger row = i / colCount;
            NSInteger col = i % colCount;
            CGFloat margin = (itemsViewSize.width - (itemWidth * colCount)) / (colCount + 1);
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
    
    UINib *itemViewNib = [UINib nibWithNibName:@"BBTurntableResultItemView" bundle:nil];
    NSMutableArray<BBTurntableResultItemView *> *itemViewList = [NSMutableArray array];
    NSInteger totalPrice = 0;
    
    BOOL needShake = NO;
    JFLotteryResultItem *maxPriceItem = nil;
    for (JFLotteryResultItem *item in models) {
        if (item.goldPrice >= 5000) {
            needShake = YES;
            maxPriceItem = item;
        }
        
        totalPrice += item.goldPrice * item.num;
        BBTurntableResultItemView *itemView = [itemViewNib instantiateWithOwner:nil options:nil].firstObject;
        itemView.model = item;
        [itemViewList addObject:itemView];
    }
    
    if (needShake) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    self.totalPriceLabel.text = [NSString stringWithFormat:@"礼物总值:%ld", totalPrice];
    
    [self expandItemViewsWithItemViewList:itemViewList];
}

@end
