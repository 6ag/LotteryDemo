//
//  JFTwistedEggResultView.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFTwistedEggResultView.h"
#import "JFTwistedEggResultItemView.h"
#import "JFHttpRequestHelper.h"
#import <AudioToolbox/AudioToolbox.h>

@interface JFTwistedEggResultView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *itemsView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@end

@implementation JFTwistedEggResultView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models
{
    JFTwistedEggResultView *view = [[NSBundle mainBundle]loadNibNamed:@"JFTwistedEggResultView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    view.models = models;
    view.contentView.alpha = 0;
    [UIView animateWithDuration:0.28 animations:^{
        view.contentView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - Event
- (IBAction)onTapCover:(id)sender
{
    [self removeFromSuperview];
}

/// 展开itemView
/// @param itemViewList 视图集合
- (void)expandItemViewsWithItemViewList:(NSMutableArray<JFTwistedEggResultItemView *> *)itemViewList
{
    [self layoutIfNeeded];
    
    NSInteger colCount = 3;
    CGFloat itemWidth = 90;
    CGFloat itemHeight = 125;
    
    for (int i = 0; i < itemViewList.count; i++) {
        JFTwistedEggResultItemView *itemView = itemViewList[i];
        itemView.frame = CGRectMake(0, 0, itemWidth, itemHeight);
        itemView.center = CGPointMake(kScreenWidth * 0.5, self.itemsView.height * 0.5);
        itemView.alpha = 0;
        
        [self.itemsView addSubview:itemView];
    }
    
    [UIView animateWithDuration:0.28 animations:^{
        for (int i = 0; i < itemViewList.count; i++) {
            JFTwistedEggResultItemView *itemView = itemViewList[i];
            
            NSInteger row = i / colCount;
            NSInteger col = i % colCount;
            CGFloat margin = (kScreenWidth - (itemWidth * colCount)) / (colCount + 1);
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
    
    UINib *itemViewNib = [UINib nibWithNibName:@"JFTwistedEggResultItemView" bundle:nil];
    NSMutableArray<JFTwistedEggResultItemView *> *itemViewList = [NSMutableArray array];
    NSInteger totalPrice = 0;
    
    BOOL needShake = NO;
    for (JFLotteryResultItem *item in models) {
        
        // 判断礼物价值是否需要开启震动
        if (item.goldPrice >= 5000) {
            needShake = YES;
        }
        
        // 计算总价值
        totalPrice += item.goldPrice * item.num;
        
        // 创建礼物item视图
        JFTwistedEggResultItemView *itemView = [itemViewNib instantiateWithOwner:nil options:nil].firstObject;
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
