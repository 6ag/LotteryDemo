//
//  JFMakeCandyResultView.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFMakeCandyResultView.h"
#import "JFMakeCandyResultItemView.h"
#import <AudioToolbox/AudioToolbox.h>

@interface JFMakeCandyResultView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *itemsView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *items_height;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@end

@implementation JFMakeCandyResultView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models
{
    JFMakeCandyResultView *view = [[NSBundle mainBundle] loadNibNamed:@"JFMakeCandyResultView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    view.models = models;
    
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

/// 展开itemView
/// @param itemViewList 视图集合
- (void)expandItemViewsWithItemViewList:(NSMutableArray<JFMakeCandyResultItemView *> *)itemViewList
{
    [self layoutIfNeeded];
    
    if (itemViewList.count == 1) {
        JFMakeCandyResultItemView *itemView = itemViewList[0];
        itemView.frame = CGRectMake(0, 0, 90, 100);
        itemView.center = CGPointMake(self.itemsView.width * 0.5, self.itemsView.height * 0.5);
        itemView.alpha = 1;
        itemView.top_nameLabel.constant = 3;
        itemView.top_priceLabel.constant = 1;
        itemView.nameLabel.font = JFFontPingFangSCRegular(14);
        itemView.priceLabel.font = JFFontPingFangSCRegular(12);
        itemView.numLabel.font = JFFontPingFangSCRegular(12);
        [self.itemsView addSubview:itemView];
    } else {
        NSInteger colCount = 4;
        CGFloat itemWidth = self.itemsView.width / colCount;
        CGFloat itemHeight = 100;
        
        // 为了让2/3个礼物也居中
        CGFloat offsetX = 0;
        if (itemViewList.count == 2) {
            offsetX = itemWidth;
        } else if (itemViewList.count == 3) {
            offsetX = itemWidth * 0.5;
        }
        
        for (int i = 0; i < itemViewList.count; i++) {
            JFMakeCandyResultItemView *itemView = itemViewList[i];
            itemView.frame = CGRectMake(0, 0, itemWidth, itemHeight);
            itemView.center = CGPointMake(self.itemsView.width * 0.5, self.itemsView.height * 0.5);
            itemView.alpha = 0;
            itemView.top_nameLabel.constant = 2;
            itemView.top_priceLabel.constant = 0;
            itemView.nameLabel.font = JFFontPingFangSCRegular(12);
            itemView.priceLabel.font = JFFontPingFangSCRegular(10);
            itemView.numLabel.font = JFFontPingFangSCRegular(10);
            [self.itemsView addSubview:itemView];
        }
        
        [UIView animateWithDuration:0.28 animations:^{
            for (int i = 0; i < itemViewList.count; i++) {
                JFMakeCandyResultItemView *itemView = itemViewList[i];
                
                NSInteger row = i / colCount;
                NSInteger col = i % colCount;
                CGFloat margin = (self.itemsView.width - (itemWidth * colCount)) / (colCount + 1);
                CGFloat x = margin + (itemWidth + margin) * col + offsetX;
                CGFloat y = itemHeight * row + (row * 15);
                
                itemView.frame = CGRectMake(x, y, itemWidth, itemHeight);
                
                itemView.alpha = 1;
            }
        }];
    }
}

#pragma mark - setter/getter
- (void)setModels:(NSArray<JFLotteryResultItem *> *)models
{
    _models = models;
    
    UINib *itemViewNib = [UINib nibWithNibName:@"JFMakeCandyResultItemView" bundle:nil];
    NSMutableArray<JFMakeCandyResultItemView *> *itemViewList = [NSMutableArray array];
    NSInteger totalPrice = 0;
    
    BOOL needShake = NO;
    JFLotteryResultItem *maxPriceItem = nil;
    for (JFLotteryResultItem *item in models) {
        if (item.goldPrice >= 5000) {
            needShake = YES;
            maxPriceItem = item;
        }
        
        totalPrice += item.goldPrice * item.num;
        JFMakeCandyResultItemView *itemView = [itemViewNib instantiateWithOwner:nil options:nil].firstObject;
        itemView.model = item;
        
        if (itemViewList.count < 12) {
            [itemViewList addObject:itemView];
        }
    }
    
    if (itemViewList.count > 8) {
        self.items_height.constant = 330;
    } else if (itemViewList.count > 4) {
        self.items_height.constant = 220;
    } else if (itemViewList.count > 1) {
        self.items_height.constant = 130;
    } else if (itemViewList.count == 1) {
        self.items_height.constant = 145;
    }
    
    if (needShake) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    self.totalPriceLabel.text = [NSString stringWithFormat:@"总价值: %ld", totalPrice];
    
    [self expandItemViewsWithItemViewList:itemViewList];
}

@end
