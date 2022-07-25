//
//  JFMoonTreasureResultView.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFMoonTreasureResultView.h"
#import "JFMoonTreasureResultItemView.h"
#import "JFHttpRequestHelper.h"
#import <AudioToolbox/AudioToolbox.h>

#define CONTENT_VIEW_HEIGHT (kScreenWidth/(375.0/500.0))

@interface JFMoonTreasureResultView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *itemsView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@end

@implementation JFMoonTreasureResultView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setupBgView:self.contentView rect:CGRectMake(0, 0, kScreenWidth, CONTENT_VIEW_HEIGHT)];
}

- (void)setupBgView:(UIView *)view rect:(CGRect)rect
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(15, 15)];
    CAShapeLayer * maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = rect;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models
{
    JFMoonTreasureResultView *view = [[NSBundle mainBundle]loadNibNamed:@"JFMoonTreasureResultView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    view.models = models;
    
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

/// 展开itemView
/// @param itemViewList 视图集合
- (void)expandItemViewsWithItemViewList:(NSMutableArray<JFMoonTreasureResultItemView *> *)itemViewList
{
    [self layoutIfNeeded];
    
    NSInteger colCount = 3;
    CGFloat itemWidth = kScreenWidth / 3.0;
    CGFloat itemHeight = kScreenWidth / 3.0 + 20;
    
    for (int i = 0; i < itemViewList.count; i++) {
        JFMoonTreasureResultItemView *itemView = itemViewList[i];
        itemView.frame = CGRectMake(0, 0, itemWidth, itemHeight);
        itemView.center = CGPointMake(kScreenWidth * 0.5, self.itemsView.height * 0.5);
        itemView.alpha = 0;
        
        [self.itemsView addSubview:itemView];
    }
    
    if (itemViewList.count > 1) {
        [UIView animateWithDuration:0.28 animations:^{
            for (int i = 0; i < itemViewList.count; i++) {
                JFMoonTreasureResultItemView *itemView = itemViewList[i];
                
                NSInteger row = i / colCount;
                NSInteger col = i % colCount;
                CGFloat margin = (kScreenWidth - (itemWidth * colCount)) / (colCount + 1);
                CGFloat x = margin + (itemWidth + margin) * col;
                CGFloat y = itemHeight * row;
                
                itemView.frame = CGRectMake(x, y, itemWidth, itemHeight);
                itemView.alpha = 1;
            }
        }];
    } else if (itemViewList.count == 1) {
        itemViewList[0].alpha = 1;
    }
}

#pragma mark - setter/getter
- (void)setModels:(NSArray<JFLotteryResultItem *> *)models
{
    _models = models;
    
    UINib *itemViewNib = [UINib nibWithNibName:@"JFMoonTreasureResultItemView" bundle:nil];
    NSMutableArray<JFMoonTreasureResultItemView *> *itemViewList = [NSMutableArray array];
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
        JFMoonTreasureResultItemView *itemView = [itemViewNib instantiateWithOwner:nil options:nil].firstObject;
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
