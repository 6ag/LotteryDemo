//
//  DDTurntableResultView.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "DDTurntableResultView.h"
#import "DDTurntableResultItemView.h"
#import <AudioToolbox/AudioToolbox.h>

@interface DDTurntableResultView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *itemsView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *content_height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *items_height;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@end

@implementation DDTurntableResultView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models
{
    DDTurntableResultView *view = [[NSBundle mainBundle] loadNibNamed:@"DDTurntableResultView" owner:self options:nil][0];
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

- (IBAction)onClickAgainBtn:(id)sender
{
    [self onTapCover:nil];
}

/// 展开itemView
/// @param itemViewList 视图集合
- (void)expandItemViewsWithItemViewList:(NSMutableArray<DDTurntableResultItemView *> *)itemViewList
{
    [self layoutIfNeeded];
    
    if (itemViewList.count == 1) {
        DDTurntableResultItemView *itemView = itemViewList[0];
        itemView.frame = CGRectMake(0, 0, 92, 135);
        itemView.center = CGPointMake(self.itemsView.width * 0.5, self.itemsView.height * 0.5);
        itemView.alpha = 1;
        itemView.top_nameLabel.constant = 8;
        itemView.top_priceLabel.constant = 2;
        itemView.nameLabel.font = JFFontPingFangSCRegular(15);
        itemView.priceLabel.font = JFFontPingFangSCRegular(12);
        itemView.numLabel.font = JFFontPingFangSCRegular(12);
        [self.itemsView addSubview:itemView];
    } else {
        NSInteger colCount = 4;
        CGFloat itemWidth = (self.itemsView.width - 30 - 40) / colCount;
        CGFloat itemHeight = 110;
        
        for (int i = 0; i < itemViewList.count; i++) {
            DDTurntableResultItemView *itemView = itemViewList[i];
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
                DDTurntableResultItemView *itemView = itemViewList[i];
                
                NSInteger row = i / colCount;
                NSInteger col = i % colCount;
                CGFloat margin = (self.itemsView.width - (itemWidth * colCount)) / (colCount + 1);
                CGFloat x = margin + (itemWidth + margin) * col;
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
    
    UINib *itemViewNib = [UINib nibWithNibName:@"DDTurntableResultItemView" bundle:nil];
    NSMutableArray<DDTurntableResultItemView *> *itemViewList = [NSMutableArray array];
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
        DDTurntableResultItemView *itemView = [itemViewNib instantiateWithOwner:nil options:nil].firstObject;
        itemView.model = item;
        
        // 最多显示12个
        if (itemViewList.count < 12) {
            [itemViewList addObject:itemView];
        }
    }
    
    if (itemViewList.count > 8) {
        self.items_height.constant = 345;
        self.content_height.constant = 505;
    } else if (itemViewList.count > 4) {
        self.items_height.constant = 235;
        self.content_height.constant = 395;
    } else if (itemViewList.count > 1) {
        self.items_height.constant = 140;
        self.content_height.constant = 300;
    } else {
        self.items_height.constant = 140;
        self.content_height.constant = 300;
    }
    
    if (needShake) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    self.totalPriceLabel.text = [NSString stringWithFormat:@"总价值: %ld", totalPrice];
    
    [self expandItemViewsWithItemViewList:itemViewList];
}

@end
