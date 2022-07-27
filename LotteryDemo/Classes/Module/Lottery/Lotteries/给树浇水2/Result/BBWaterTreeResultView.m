//
//  BBWaterTreeResultView.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "BBWaterTreeResultView.h"
#import "BBWaterTreeResultItemView.h"
#import <AudioToolbox/AudioToolbox.h>

@interface BBWaterTreeResultView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *itemsView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;
@property (nonatomic, copy) ClickableCallback callback;

@end

@implementation BBWaterTreeResultView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models callback:(ClickableCallback)callback
{
    BBWaterTreeResultView *view = [[NSBundle mainBundle] loadNibNamed:@"BBWaterTreeResultView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    view.alpha = 0;
    
    view.models = models;
    view.callback = callback;
    
    view.alpha = 0;
    [UIView animateWithDuration:0.28 animations:^{
        view.alpha = 1;
    }];
    
    view.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        view.userInteractionEnabled = YES;
    });
}

#pragma mark - Event
- (IBAction)onTapCover:(id)sender
{
    [self removeFromSuperview];
    
    if (self.callback) {
        self.callback();
    }
}

/// 展开itemView
/// @param itemViewList 视图集合
- (void)expandItemViewsWithItemViewList:(NSMutableArray<BBWaterTreeResultItemView *> *)itemViewList
{
    [self layoutIfNeeded];
    
    if (itemViewList.count == 1) {
        BBWaterTreeResultItemView *itemView = itemViewList[0];
        itemView.frame = CGRectMake(self.itemsView.width * 0.5 - 45, 45, 90, 110);
        itemView.alpha = 1;
        itemView.top_nameLabel.constant = 4;
        itemView.top_priceLabel.constant = 1;
        itemView.nameLabel.font = JFFontPingFangSCRegular(14);
        itemView.priceLabel.font = JFFontPingFangSCRegular(12);
        itemView.numLabel.font = JFFontPingFangSCMedium(13);
        [self.itemsView addSubview:itemView];
    } else {
        NSInteger colCount = 4;
        CGFloat itemWidth = self.itemsView.width / colCount;
        CGFloat itemHeight = 110;
        
        // 为了让2/3个礼物也居中
        CGFloat offsetX = 0;
        if (itemViewList.count == 2) {
            offsetX = itemWidth;
        } else if (itemViewList.count == 3) {
            offsetX = itemWidth * 0.5;
        }
        
        for (int i = 0; i < itemViewList.count; i++) {
            BBWaterTreeResultItemView *itemView = itemViewList[i];
            itemView.frame = CGRectMake(0, 0, itemWidth, itemHeight);
            itemView.center = CGPointMake(self.itemsView.width * 0.5, self.itemsView.height * 0.5);
            itemView.alpha = 0;
            itemView.top_nameLabel.constant = 2;
            itemView.top_priceLabel.constant = 0;
            itemView.nameLabel.font = JFFontPingFangSCRegular(12);
            itemView.priceLabel.font = JFFontPingFangSCRegular(11);
            itemView.numLabel.font = JFFontPingFangSCMedium(12);
            [self.itemsView addSubview:itemView];
        }
        
        [UIView animateWithDuration:0.28 animations:^{
            for (int i = 0; i < itemViewList.count; i++) {
                BBWaterTreeResultItemView *itemView = itemViewList[i];
                
                NSInteger row = i / colCount;
                NSInteger col = i % colCount;
                CGFloat margin = (self.itemsView.width - (itemWidth * colCount)) / (colCount + 1);
                CGFloat x = margin + (itemWidth + margin) * col + offsetX;
                CGFloat y = itemHeight * row + (row * 15);
                
                if (itemViewList.count < 4) {
                    itemView.frame = CGRectMake(x, 45, itemWidth, itemHeight);
                } else {
                    itemView.frame = CGRectMake(x, y, itemWidth, itemHeight);
                }
                
                itemView.alpha = 1;
            }
        }];
    }
    
}

#pragma mark - setter/getter
- (void)setModels:(NSArray<JFLotteryResultItem *> *)models
{
    _models = models;
    
    UINib *itemViewNib = [UINib nibWithNibName:@"BBWaterTreeResultItemView" bundle:nil];
    NSMutableArray<BBWaterTreeResultItemView *> *itemViewList = [NSMutableArray array];
    NSInteger totalPrice = 0;
    
    BOOL needShake = NO;
    for (JFLotteryResultItem *item in models) {
        if (item.goldPrice >= 5000) {
            needShake = YES;
        }
        
        totalPrice += item.goldPrice * item.num;
        BBWaterTreeResultItemView *itemView = [itemViewNib instantiateWithOwner:nil options:nil].firstObject;
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
