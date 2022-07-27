//
//  JFDragonSlayerBigResultView.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFDragonSlayerBigResultView.h"
#import "JFDragonSlayerBigResultItemView.h"
#import "JFHttpRequestHelper.h"

@interface JFDragonSlayerBigResultView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *itemsView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *content_height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *items_height;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@end

@implementation JFDragonSlayerBigResultView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models
{
    JFDragonSlayerBigResultView *view = [[NSBundle mainBundle] loadNibNamed:@"JFDragonSlayerBigResultView" owner:self options:nil][0];
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
- (void)expandItemViewsWithItemViewList:(NSMutableArray<JFDragonSlayerBigResultItemView *> *)itemViewList
{
    [self layoutIfNeeded];
    
    NSInteger colCount = 3;
    CGFloat itemWidth = (kScreenWidth - 78 - 40) / 3;
    CGFloat itemHeight = 110;
    
    for (int i = 0; i < itemViewList.count; i++) {
        JFDragonSlayerBigResultItemView *itemView = itemViewList[i];
        itemView.frame = CGRectMake(0, 0, itemWidth, itemHeight);
        itemView.center = CGPointMake((kScreenWidth - 100) * 0.5, self.itemsView.height * 0.5);
        itemView.alpha = 0;
        
        [self.itemsView addSubview:itemView];
    }
    
    if (itemViewList.count == 1) {
        for (int i = 0; i < itemViewList.count; i++) {
            JFDragonSlayerBigResultItemView *itemView = itemViewList[i];
            itemView.alpha = 1;
        }
        return;
    }
    
    if (itemViewList.count == 2) {
        colCount = 2;
    }
    
    [UIView animateWithDuration:0.28 animations:^{
        for (int i = 0; i < itemViewList.count; i++) {
            JFDragonSlayerBigResultItemView *itemView = itemViewList[i];
            
            NSInteger row = i / colCount;
            NSInteger col = i % colCount;
            CGFloat margin = ((kScreenWidth - 100) - (itemWidth * colCount)) / (colCount + 1);
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
    
    UINib *itemViewNib = [UINib nibWithNibName:@"JFDragonSlayerBigResultItemView" bundle:nil];
    NSMutableArray<JFDragonSlayerBigResultItemView *> *itemViewList = [NSMutableArray array];
    
    for (JFLotteryResultItem *item in models) {
        if (item.goldPrice >= 2000 && itemViewList.count <= 6) {
            JFDragonSlayerBigResultItemView *itemView = [itemViewNib instantiateWithOwner:nil options:nil].firstObject;
            itemView.model = item;
            [itemViewList addObject:itemView];
        }
    }
    
    if (itemViewList.count > 3) {
        self.items_height.constant = 235;
        self.content_height.constant = 395;
    }
    
    [self expandItemViewsWithItemViewList:itemViewList];
}

@end
