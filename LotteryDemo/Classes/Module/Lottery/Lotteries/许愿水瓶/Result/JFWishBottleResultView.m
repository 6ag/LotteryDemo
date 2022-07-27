//
//  JFWishBottleResultView.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFWishBottleResultView.h"
#import "JFWishBottleResultItemView.h"
#import <AudioToolbox/AudioToolbox.h>

@interface JFWishBottleResultView ()

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *itemsView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height_contentView;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;
@property (nonatomic, copy) TwistedEggResultFinished finished;

@end

@implementation JFWishBottleResultView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models isLuxury:(BOOL)isLuxury finished:(TwistedEggResultFinished)finished
{
    JFWishBottleResultView *view = [[NSBundle mainBundle]loadNibNamed:@"JFWishBottleResultView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    view.alpha = 0;
    view.userInteractionEnabled = NO;
    
    view.models = models;
    view.finished = finished;
    
    if (models.count <= 3) {
        view.height_contentView.constant = 300;
    } else if (models.count <= 6) {
        view.height_contentView.constant = 415;
    } else if (models.count <= 9) {
        view.height_contentView.constant = 545;
    }
    
    [UIView animateWithDuration:0.28 animations:^{
        view.alpha = 1;
    } completion:^(BOOL finished) {
        view.userInteractionEnabled = YES;
    }];
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
- (void)expandItemViewsWithItemViewList:(NSMutableArray<JFWishBottleResultItemView *> *)itemViewList
{
    [self layoutIfNeeded];
    
    NSInteger colCount = 3;
    CGFloat itemWidth = self.itemsView.width / colCount;
    CGFloat itemHeight = 115;
    
    for (int i = 0; i < itemViewList.count; i++) {
        JFWishBottleResultItemView *itemView = itemViewList[i];
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
            JFWishBottleResultItemView *itemView = itemViewList[i];
            itemView.frame = CGRectMake(0, 0, 120, 145);
            itemView.center = CGPointMake(self.itemsView.width * 0.5, self.itemsView.height * 0.25 + 10);
            
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
            JFWishBottleResultItemView *itemView = itemViewList[i];
            
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
    
    UINib *itemViewNib = [UINib nibWithNibName:@"JFWishBottleResultItemView" bundle:nil];
    NSMutableArray<JFWishBottleResultItemView *> *itemViewList = [NSMutableArray array];
    
    NSInteger totalPrice = 0;
    BOOL isDouble = YES;
    BOOL needShake = NO;
    for (JFLotteryResultItem *item in models) {
        if (item.goldPrice >= 5000) {
            needShake = YES;
        }
        
        totalPrice += item.goldPrice * item.num;
        JFWishBottleResultItemView *itemView = [itemViewNib instantiateWithOwner:nil options:nil].firstObject;
        itemView.model = item;
        [itemViewList addObject:itemView];
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
