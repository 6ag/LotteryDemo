//
//  HHTurntableResultView.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "HHTurntableResultView.h"
#import "HHTurntableResultItemView.h"
#import <AudioToolbox/AudioToolbox.h>

@interface HHTurntableResultView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *itemsView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *items_height;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@end

@implementation HHTurntableResultView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models
{
    HHTurntableResultView *view = [[NSBundle mainBundle] loadNibNamed:@"HHTurntableResultView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    view.models = models;
    
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
}

/// 展开itemView
/// @param itemViewList 视图集合
- (void)expandItemViewsWithItemViewList:(NSMutableArray<HHTurntableResultItemView *> *)itemViewList
{
    [self layoutIfNeeded];
    
    NSInteger colCount = 4;
    CGFloat itemWidth = (SCREEN_WIDTH - 25 * 2) / colCount;
    CGFloat itemHeight = 110;
    
    for (int i = 0; i < itemViewList.count; i++) {
        HHTurntableResultItemView *itemView = itemViewList[i];
        itemView.frame = CGRectMake(0, 0, itemWidth, itemHeight);
        if (itemViewList.count > 1) {
            itemView.logoImageView.layer.cornerRadius = (itemWidth - 7 * 2 - 5 * 2) * 0.5;
        }
        itemView.center = CGPointMake(self.itemsView.width * 0.5, self.itemsView.height * 0.5);
        itemView.alpha = 0;
        
        [self.itemsView addSubview:itemView];
    }
    
    if (itemViewList.count == 1) {
        for (int i = 0; i < itemViewList.count; i++) {
            HHTurntableResultItemView *itemView = itemViewList[i];
            itemView.frame = CGRectMake(0, 0, 95, 150);
            itemView.center = CGPointMake(self.itemsView.width * 0.5, self.itemsView.height * 0.6);
            
            itemView.left_logo.constant = 15;
            itemView.top_logo.constant = 15;
            itemView.right_logo.constant = 15;
            itemView.bottom_logo.constant = 15;
            itemView.top_name.constant = 8;
            
            itemView.alpha = 1;
        }
        return;
    }
    
    if (itemViewList.count == 2) {
        colCount = 2;
    }
    
    if (itemViewList.count == 3) {
        colCount = 3;
    }
    
    [UIView animateWithDuration:0.28 animations:^{
        for (int i = 0; i < itemViewList.count; i++) {
            HHTurntableResultItemView *itemView = itemViewList[i];
            
            NSInteger row = i / colCount;
            NSInteger col = i % colCount;
            CGFloat margin = (self.itemsView.width - (itemWidth * colCount)) / (colCount + 1);
            CGFloat x = margin + (itemWidth + margin) * col;
            CGFloat y = itemHeight * row + (row * 15);
            
            if (itemViewList.count <= 4) {
                y += 30;
            }
            itemView.frame = CGRectMake(x, y, itemWidth, itemHeight);
            
            itemView.alpha = 1;
        }
    }];
    
}

#pragma mark - setter/getter
- (void)setModels:(NSArray<JFLotteryResultItem *> *)models
{
    _models = models;
    
    UINib *itemViewNib = [UINib nibWithNibName:@"HHTurntableResultItemView" bundle:nil];
    NSMutableArray<HHTurntableResultItemView *> *itemViewList = [NSMutableArray array];
    NSInteger totalPrice = 0;
    
    BOOL needShake = NO;
    for (JFLotteryResultItem *item in models) {
        if (item.goldPrice >= 5000) {
            needShake = YES;
        }
        
        totalPrice += item.goldPrice * item.num;
        HHTurntableResultItemView *itemView = [itemViewNib instantiateWithOwner:nil options:nil].firstObject;
        itemView.model = item;
        [itemViewList addObject:itemView];
    }
    
    if (itemViewList.count > 8) {
        self.items_height.constant = 360;
    } else if (itemViewList.count > 4) {
        self.items_height.constant = 260;
    } else if (itemViewList.count > 1) {
        self.items_height.constant = 180;
    } else {
        self.items_height.constant = 180;
    }
    
    if (needShake) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    self.totalPriceLabel.text = [NSString stringWithFormat:@"礼物总值:%ld", totalPrice];
    [self expandItemViewsWithItemViewList:itemViewList];
}

@end
