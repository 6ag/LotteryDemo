//
//  JFDreamBubbleResultView.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFDreamBubbleResultView.h"
#import "JFDreamBubbleResultItemView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "JFDreamBubbleDoubleView.h"

@interface JFDreamBubbleResultView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *itemsView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@property (nonatomic, copy) DreamBubbleResultFinished finished;

@end

@implementation JFDreamBubbleResultView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models isLuxury:(BOOL)isLuxury finished:(DreamBubbleResultFinished)finished
{
    JFDreamBubbleResultView *view = [[NSBundle mainBundle]loadNibNamed:@"JFDreamBubbleResultView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    view.alpha = 0;
    view.userInteractionEnabled = NO;
    
    view.models = models;
    view.finished = finished;
    
    BOOL isShowDoubleView = models.count >= 5;
    if (isShowDoubleView) {
        [UIView animateWithDuration:0.28 animations:^{
            view.alpha = 1;
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (isShowDoubleView) {
                [JFDreamBubbleDoubleView showWish:models finished:^{
                    view.userInteractionEnabled = YES;
                }];
            } else {
                view.userInteractionEnabled = YES;
            }
        });
    } else {
        [UIView animateWithDuration:0.28 animations:^{
            view.alpha = 1;
        } completion:^(BOOL finished) {
            view.userInteractionEnabled = YES;
        }];
    }
}

#pragma mark - Event
- (IBAction)onTapCover:(id)sender
{
    [self removeFromSuperview];
    if (self.finished) {
        self.finished();
    }
}

/// 展开itemView
/// @param itemViewList 视图集合
- (void)expandItemViewsWithItemViewList:(NSMutableArray<JFDreamBubbleResultItemView *> *)itemViewList
{
    [self layoutIfNeeded];
    
    NSInteger colCount = 3;
    CGFloat itemWidth = self.itemsView.width / colCount;
    CGFloat itemHeight = 95;
    
    for (int i = 0; i < itemViewList.count; i++) {
        JFDreamBubbleResultItemView *itemView = itemViewList[i];
        itemView.frame = CGRectMake(0, 0, itemWidth, itemHeight);
        if (itemViewList.count > 1) {
            itemView.logoImageView.layer.cornerRadius = (itemWidth - 15 * 2 - 5 * 2) * 0.5;
        }
        itemView.center = CGPointMake(self.itemsView.width * 0.5, self.itemsView.height * 0.5);
        itemView.alpha = 0;
        
        [self.itemsView addSubview:itemView];
    }
    
    if (itemViewList.count == 1) {
        for (int i = 0; i < itemViewList.count; i++) {
            JFDreamBubbleResultItemView *itemView = itemViewList[i];
            itemView.frame = CGRectMake(0, 0, 120, 145);
            itemView.center = CGPointMake(self.itemsView.width * 0.5, self.itemsView.height * 0.25);
            
            itemView.left_logo.constant = 15;
            itemView.top_logo.constant = 15;
            itemView.right_logo.constant = 15;
            itemView.bottom_logo.constant = 15;
            itemView.top_name.constant = 5;
            
            itemView.alpha = 1;
        }
        return;
    }
    
    if (itemViewList.count == 2) {
        colCount = 2;
    }
    
    [UIView animateWithDuration:0.28 animations:^{
        for (int i = 0; i < itemViewList.count; i++) {
            JFDreamBubbleResultItemView *itemView = itemViewList[i];
            
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
    
    UINib *itemViewNib = [UINib nibWithNibName:@"JFDreamBubbleResultItemView" bundle:nil];
    NSMutableArray<JFDreamBubbleResultItemView *> *itemViewList = [NSMutableArray array];
    NSInteger totalPrice = 0;
    
    BOOL isDouble = YES;
    NSInteger bigCount = 0;
    BOOL needShake = NO;
    
    for (JFLotteryResultItem *item in models) {
        
        // 判断礼物价值是否需要开启震动
        if (item.goldPrice >= 5000) {
            needShake = YES;
        }
        
        // 计算总价值
        totalPrice += item.goldPrice * item.num;
        
        // 创建礼物item视图
        JFDreamBubbleResultItemView *itemView = [itemViewNib instantiateWithOwner:nil options:nil].firstObject;
        itemView.model = item;
        [itemViewList addObject:itemView];
        
        if (item.goldPrice >= 3344) {
            bigCount++;
        }
    }
    
    if (needShake) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    if (isDouble) {
        totalPrice *= 2;
    }
    
    self.totalPriceLabel.text = [NSString stringWithFormat:@"礼物总值: %ld", totalPrice];
    [self expandItemViewsWithItemViewList:itemViewList];
}

@end
