//
//  JFCatteryResultView.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFCatteryResultView.h"
#import "JFCatteryResultItemView.h"
#import "JFHttpRequestHelper.h"
#import <AudioToolbox/AudioToolbox.h>

@interface JFCatteryResultView ()

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *itemsView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *items_height;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top_itemsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_itemsView;

@property (nonatomic, copy) ClickableCallback callback;

@end

@implementation JFCatteryResultView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models callback:(ClickableCallback)callback
{
    JFCatteryResultView *view = [[NSBundle mainBundle] loadNibNamed:@"JFCatteryResultView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    view.models = models;
    view.callback = callback;
    
    view.alpha = 0;
    [UIView animateWithDuration:0.28 animations:^{
        view.alpha = 1;
    }];
    
    view.coverView.userInteractionEnabled = NO;
    view.closeBtn.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        view.coverView.userInteractionEnabled = YES;
        view.closeBtn.userInteractionEnabled = YES;
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
- (void)expandItemViewsWithItemViewList:(NSMutableArray<JFCatteryResultItemView *> *)itemViewList
{
    [self layoutIfNeeded];
    
    NSInteger colCount = 4;
    CGFloat itemWidth = (kScreenWidth - 110) / colCount;
    CGFloat itemHeight = 100;
    
    for (int i = 0; i < itemViewList.count; i++) {
        JFCatteryResultItemView *itemView = itemViewList[i];
        itemView.frame = CGRectMake(0, 0, itemWidth, itemHeight);
        itemView.center = CGPointMake(self.itemsView.width * 0.5, self.itemsView.height * 0.5);
        itemView.alpha = 0;
        
        [self.itemsView addSubview:itemView];
    }
    
    if (itemViewList.count == 1) {
        for (int i = 0; i < itemViewList.count; i++) {
            JFCatteryResultItemView *itemView = itemViewList[i];
            itemView.frame = CGRectMake(0, 10, 107, 145);
            itemView.center = CGPointMake(self.itemsView.width * 0.5, self.itemsView.height * 0.5);
            
            itemView.top_name.constant = 5;
            itemView.alpha = 1;
            
            itemView.nameLabel.font = JFFontPingFangSCRegular(14);
            itemView.numLabel.font = JFFontPingFangSCRegular(12);
            itemView.priceLabel.font = JFFontPingFangSCRegular(12);
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
            JFCatteryResultItemView *itemView = itemViewList[i];
            
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

#pragma mark - setter/getter
- (void)setModels:(NSArray<JFLotteryResultItem *> *)models
{
    _models = models;
    
    UINib *itemViewNib = [UINib nibWithNibName:@"JFCatteryResultItemView" bundle:nil];
    NSMutableArray<JFCatteryResultItemView *> *itemViewList = [NSMutableArray array];
    NSInteger totalPrice = 0;
    
    BOOL needShake = NO;
    for (JFLotteryResultItem *item in models) {
        // 判断礼物价值是否需要开启震动
        if (item.goldPrice >= 5000) {
            needShake = YES;
        }
        
        // 计算总价值
        totalPrice += item.goldPrice * item.num;
        
        JFCatteryResultItemView *itemView = [itemViewNib instantiateWithOwner:nil options:nil].firstObject;
        itemView.model = item;
        [itemViewList addObject:itemView];
    }
    
    if (itemViewList.count > 8) {
        self.items_height.constant = 360;
    } else if (itemViewList.count > 4) {
        self.items_height.constant = 200;
    } else if (itemViewList.count > 1) {
        self.items_height.constant = 200;
    } else {
        self.items_height.constant = 200;
    }
    
    if (needShake) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    self.totalPriceLabel.text = [NSString stringWithFormat:@"礼物总值:%ld", totalPrice];
    [self expandItemViewsWithItemViewList:itemViewList];
}

@end
