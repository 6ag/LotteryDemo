//
//  JFMiningResultView.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFMiningResultView.h"
#import "JFMiningResultItemView.h"
#import <AudioToolbox/AudioToolbox.h>

@interface JFMiningResultView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *itemsView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) JFRoomWishAgain againBlock;

@end

@implementation JFMiningResultView

- (void)awakeFromNib
{
    [super awakeFromNib];
}

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models type:(NSInteger)type againBlock:(JFRoomWishAgain)againBlock
{
    JFMiningResultView *view = [[NSBundle mainBundle]loadNibNamed:@"JFMiningResultView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    view.models = models;
    view.type = type;
    view.againBlock = againBlock;
    
    view.contentView.alpha = 0;
    [UIView animateWithDuration:0.28 animations:^{
        view.contentView.alpha = 1;
    }];
}

#pragma mark - Event
- (IBAction)onTapCover:(id)sender
{
    [self removeFromSuperview];
}

- (IBAction)onClickAgainBtn:(id)sender
{
    if (self.againBlock) {
        self.againBlock(self.type);
    }
    [self onTapCover:nil];
}

/// 展开itemView
/// @param itemViewList 视图集合
- (void)expandItemViewsWithItemViewList:(NSMutableArray<JFMiningResultItemView *> *)itemViewList
{
    [self layoutIfNeeded];
    
    NSInteger colCount = 3;
    CGFloat itemWidth = (kScreenWidth - 28) / 3.0;
    CGFloat itemHeight = (kScreenWidth - 28) / 3.0 + 20;
    
    for (int i = 0; i < itemViewList.count; i++) {
        JFMiningResultItemView *itemView = itemViewList[i];
        itemView.frame = CGRectMake(0, 0, itemWidth, itemHeight);
        itemView.center = CGPointMake((kScreenWidth - 28) * 0.5, self.itemsView.height * 0.5);
        itemView.alpha = 0;
        
        [self.itemsView addSubview:itemView];
    }
    
    [UIView animateWithDuration:0.28 animations:^{
        for (int i = 0; i < itemViewList.count; i++) {
            JFMiningResultItemView *itemView = itemViewList[i];
            
            NSInteger row = i / colCount;
            NSInteger col = i % colCount;
            CGFloat margin = ((kScreenWidth - 28) - (itemWidth * colCount)) / (colCount + 1);
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
    
    UINib *itemViewNib = [UINib nibWithNibName:@"JFMiningResultItemView" bundle:nil];
    NSMutableArray<JFMiningResultItemView *> *itemViewList = [NSMutableArray array];
    NSInteger totalPrice = 0;
    
    BOOL needShake = NO;
    JFLotteryResultItem *maxPriceItem = nil;
    for (JFLotteryResultItem *item in models) {
        if (item.goldPrice >= 5000) {
            needShake = YES;
            maxPriceItem = item;
        }
        
        totalPrice += item.goldPrice * item.num;
        JFMiningResultItemView *itemView = [itemViewNib instantiateWithOwner:nil options:nil].firstObject;
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
