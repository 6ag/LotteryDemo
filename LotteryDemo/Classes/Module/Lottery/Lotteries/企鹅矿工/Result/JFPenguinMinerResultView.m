//
//  JFPenguinMinerResultView.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFPenguinMinerResultView.h"
#import "JFPenguinMinerResultItemView.h"
#import <AudioToolbox/AudioToolbox.h>

@interface JFPenguinMinerResultView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *itemsView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (weak, nonatomic) IBOutlet UIImageView *moreTopBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *moreBottomBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *oneBgImageView;

@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (weak, nonatomic) IBOutlet UIButton *oneBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *items_height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentView_centerY;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@end

@implementation JFPenguinMinerResultView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models
{
    JFPenguinMinerResultView *view = [[NSBundle mainBundle] loadNibNamed:@"JFPenguinMinerResultView" owner:self options:nil][0];
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
- (void)expandItemViewsWithItemViewList:(NSMutableArray<JFPenguinMinerResultItemView *> *)itemViewList
{
    [self layoutIfNeeded];
    
    if (itemViewList.count == 1) {
        JFPenguinMinerResultItemView *itemView = itemViewList[0];
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
        CGFloat itemHeight = 90;
        
        // 为了让2/3个礼物也居中
        CGFloat offsetX = 0;
        if (itemViewList.count == 2) {
            offsetX = itemWidth;
        } else if (itemViewList.count == 3) {
            offsetX = itemWidth * 0.5;
        }
        
        for (int i = 0; i < itemViewList.count; i++) {
            JFPenguinMinerResultItemView *itemView = itemViewList[i];
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
                JFPenguinMinerResultItemView *itemView = itemViewList[i];
                
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
    
    UINib *itemViewNib = [UINib nibWithNibName:@"JFPenguinMinerResultItemView" bundle:nil];
    NSMutableArray<JFPenguinMinerResultItemView *> *itemViewList = [NSMutableArray array];
    NSInteger totalPrice = 0;
    
    BOOL needShake = NO;
    JFLotteryResultItem *maxPriceItem = nil;
    for (JFLotteryResultItem *item in models) {
        if (item.goldPrice >= 5000) {
            needShake = YES;
            maxPriceItem = item;
        }
        
        totalPrice += item.goldPrice * item.num;
        JFPenguinMinerResultItemView *itemView = [itemViewNib instantiateWithOwner:nil options:nil].firstObject;
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
        self.items_height.constant = 200;
    } else if (itemViewList.count == 1) {
        self.items_height.constant = 150;
    }
    
    if (itemViewList.count == 1) {
        self.moreTopBgImageView.hidden = YES;
        self.moreBottomBgImageView.hidden = YES;
        self.oneBgImageView.hidden = NO;
        
        self.moreBtn.hidden = YES;
        self.oneBtn.hidden = NO;
        
        self.contentView_centerY.constant = 150;
    } else {
        self.moreTopBgImageView.hidden = NO;
        self.moreBottomBgImageView.hidden = NO;
        self.oneBgImageView.hidden = YES;
        
        self.moreBtn.hidden = NO;
        self.oneBtn.hidden = YES;
        
        self.contentView_centerY.constant = 100;
    }
    
    if (needShake) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    self.totalPriceLabel.text = [NSString stringWithFormat:@"总价值: %ld", totalPrice];
    
    [self expandItemViewsWithItemViewList:itemViewList];
}

@end
