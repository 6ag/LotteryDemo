//
//  JFUnlimitedTreasureChestResultView.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFUnlimitedTreasureChestResultView.h"
#import "JFUnlimitedTreasureChestResultItemView.h"
#import <AudioToolbox/AudioToolbox.h>

@interface JFUnlimitedTreasureChestResultView ()

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *itemsView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *items_top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *items_bottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *items_height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentView_centerY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentView_left;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentView_right;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;
@property (nonatomic, copy) ClickableCallback callback;

@end

@implementation JFUnlimitedTreasureChestResultView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models callback:(ClickableCallback)callback
{
    JFUnlimitedTreasureChestResultView *view = [[NSBundle mainBundle] loadNibNamed:@"JFUnlimitedTreasureChestResultView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    view.models = models;
    view.callback = callback;
    
    view.alpha = 0;
    [UIView animateWithDuration:0.28 animations:^{
        view.alpha = 1;
    }];
    
    view.coverView.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        view.coverView.userInteractionEnabled = YES;
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
- (void)expandItemViewsWithItemViewList:(NSMutableArray<JFUnlimitedTreasureChestResultItemView *> *)itemViewList
{
    [self layoutIfNeeded];
    
    if (itemViewList.count == 1) {
        JFUnlimitedTreasureChestResultItemView *itemView = itemViewList[0];
        itemView.frame = CGRectMake(0, 0, 100, 120);
        itemView.center = CGPointMake(self.itemsView.width * 0.5, self.itemsView.height * 0.5);
        itemView.alpha = 1;
        itemView.top_nameLabel.constant = 3;
        itemView.top_priceLabel.constant = 1;
        itemView.nameLabel.font = JFFontPingFangSCRegular(15);
        itemView.priceLabel.font = JFFontPingFangSCRegular(13);
        itemView.numLabel.font = JFFontPingFangSCRegular(13);
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
            JFUnlimitedTreasureChestResultItemView *itemView = itemViewList[i];
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
                JFUnlimitedTreasureChestResultItemView *itemView = itemViewList[i];
                
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
    
    UINib *itemViewNib = [UINib nibWithNibName:@"JFUnlimitedTreasureChestResultItemView" bundle:nil];
    NSMutableArray<JFUnlimitedTreasureChestResultItemView *> *itemViewList = [NSMutableArray array];
    NSInteger totalPrice = 0;
    
    BOOL needShake = NO;
    JFLotteryResultItem *maxPriceItem = nil;
    for (JFLotteryResultItem *item in models) {
        
        // 判断礼物价值是否需要开启震动
        if (item.goldPrice >= 5000) {
            needShake = YES;
            maxPriceItem = item;
        }
        
        // 计算总价值
        totalPrice += item.goldPrice * item.num;
        
        // 创建礼物item视图
        JFUnlimitedTreasureChestResultItemView *itemView = [itemViewNib instantiateWithOwner:nil options:nil].firstObject;
        itemView.model = item;
        
        // 最多显示12个
        if (itemViewList.count < 12) {
            [itemViewList addObject:itemView];
        }
    }
    
    self.items_top.constant = 10;
    self.items_bottom.constant = 40;
    if (itemViewList.count > 8) {
        self.items_height.constant = 330;
    } else if (itemViewList.count > 4) {
        self.items_height.constant = 220;
    } else if (itemViewList.count > 1) {
        self.items_height.constant = 150;
        self.items_top.constant = 40;
        self.items_bottom.constant = 30;
    } else if (itemViewList.count == 1) {
        self.items_height.constant = 150;
        self.items_top.constant = 20;
        self.items_bottom.constant = 50;
    }
    
    if (itemViewList.count <= 3) {
        self.contentView_left.constant = 50;
    } else {
        self.contentView_left.constant = 20;
    }
    
    
    if (needShake) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    self.totalPriceLabel.text = [NSString stringWithFormat:@"总价值: %ld", totalPrice];
    
    [self expandItemViewsWithItemViewList:itemViewList];
}

@end
