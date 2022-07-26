//
//  JFTarotView.m
//  VoiceChat
//
//  Created by feng on 2021/12/29.
//  Copyright © 2021 NoCardData. All rights reserved.
//

#import "JFTarotView.h"
#import "JFHttpRequestHelper.h"
#import "JFTarotItemView.h"

#define CONTENT_VIEW_HEIGHT (kScreenWidth/(375.0/600.0))

@interface JFTarotView ()

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *itemsView;
@property (weak, nonatomic) IBOutlet UIView *hudContainerView;

@property (weak, nonatomic) IBOutlet UIButton *typeBtn1;
@property (weak, nonatomic) IBOutlet UIButton *typeBtn2;
@property (weak, nonatomic) IBOutlet UIButton *typeBtn3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerX_lineView;

@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *priceTipLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_contentView;

@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, assign) NSInteger type;

@property (nonatomic, strong) NSMutableArray<JFTarotItemView *> *itemList;

@end

@implementation JFTarotView

+ (void)show
{
    JFTarotView *view = [[NSBundle mainBundle] loadNibNamed:@"JFTarotView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];

    view.coverView.alpha = 0;
    view.bottom_contentView.constant = -CONTENT_VIEW_HEIGHT;
    [view layoutIfNeeded];
    [UIView animateWithDuration:0.28 animations:^{
        view.coverView.alpha = 1;
        view.bottom_contentView.constant = (iPhoneX ? 0 : -20);
        [view layoutIfNeeded];
    } completion:^(BOOL finished) {
        view.type = 1;
    }];
}

- (void)closeDialog
{
    [UIView animateWithDuration:0.28 animations:^{
        self.coverView.alpha = 0;
        self.bottom_contentView.constant = -CONTENT_VIEW_HEIGHT;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Event
- (IBAction)onTapCoverView:(id)sender {
    [self closeDialog];
}

- (IBAction)onClickTypeBtn1:(id)sender {
    if ([self existAnimation]) {
        return;
    }
    self.type = 1;
    
    self.typeBtn1.selected = YES;
    self.typeBtn2.selected = NO;
    self.typeBtn3.selected = NO;
}

- (IBAction)onClickTypeBtn2:(id)sender {
    if ([self existAnimation]) {
        return;
    }
    self.type = 2;
    
    self.typeBtn1.selected = NO;
    self.typeBtn2.selected = YES;
    self.typeBtn3.selected = NO;
}

- (IBAction)onClickTypeBtn3:(id)sender {
    if ([self existAnimation]) {
        return;
    }
    self.type = 3;
    
    self.typeBtn1.selected = NO;
    self.typeBtn2.selected = NO;
    self.typeBtn3.selected = YES;
}

- (IBAction)onClickRuleBtn:(id)sender {
    
}

- (IBAction)onClickRecordBtn:(id)sender {
    
}

/// 当前类型是否存在还在进行动画的卡牌
- (BOOL)existAnimation
{
    for (JFTarotItemView *itemView in self.itemList) {
        if (itemView.isAnimation) {
            return YES;
        }
    }
    return NO;
}

/// 展开卡牌
- (void)expansionCards
{
    [self layoutIfNeeded];
    
    [self.itemsView removeAllSubviews];
    
    self.itemList = [NSMutableArray array];
    UINib *itemViewNib = [UINib nibWithNibName:@"JFTarotItemView" bundle:nil];
    
    CGFloat margin = 21;
    CGFloat itemWidth = (SCREEN_WIDTH - 35 * 2 - margin * 2) / 3;
    CGFloat itemHeight = itemWidth / 87.5 * 125;
    
    for (int i = 0; i < 8; i++) {
        JFTarotItemView *itemView = [itemViewNib instantiateWithOwner:nil options:nil].firstObject;
        [self.itemList addObject:itemView];
        
        switch (self.type) {
            case 1:
                itemView.backImageView.image = [UIImage imageNamed:@"tarot_open_card_back_1"];
                break;
            case 2:
                itemView.backImageView.image = [UIImage imageNamed:@"tarot_open_card_back_2"];
                break;
            case 3:
                itemView.backImageView.image = [UIImage imageNamed:@"tarot_open_card_back_3"];
                break;
            default:
                break;
        }
        
        itemView.frame = CGRectMake(0, 0, itemWidth, itemHeight);
        itemView.center = CGPointMake(self.itemsView.width * 0.5, self.itemsView.height * 0.5);
        itemView.alpha = 0;
        [self.itemsView addSubview:itemView];
        
        @weakify(self);
        itemView.onClickCard = ^(JFTarotItemView * _Nonnull view) {
            @strongify(self);
            [self openTarotActionWithTarotItemView:view];
        };
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        for (UIView *subView in self.itemList) {
            subView.alpha = 1;
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.28 animations:^{
            self.itemList[0].frame = CGRectMake(0, 0, itemWidth, itemHeight);
            self.itemList[1].frame = CGRectMake(itemWidth * 2 + margin * 2, 0, itemWidth, itemHeight);
            self.itemList[2].frame = CGRectMake(0, itemHeight + margin, itemWidth, itemHeight);
            self.itemList[3].frame = CGRectMake(itemWidth * 2 + margin * 2, itemHeight + margin, itemWidth, itemHeight);
            self.itemList[4].frame = CGRectMake(0, itemHeight * 2 + margin * 2, itemWidth, itemHeight);
            self.itemList[5].frame = CGRectMake(itemWidth * 2 + margin * 2, itemHeight * 2 + margin * 2, itemWidth, itemHeight);
            self.itemList[6].frame = CGRectMake(itemWidth + margin, JFWidthRadio(60), itemWidth, itemHeight);
            self.itemList[7].frame = CGRectMake(itemWidth + margin, JFWidthRadio(60) + itemHeight + JFWidthRadio(50), itemWidth, itemHeight);
        }];
    }];
}

#pragma mark - Network
- (void)openTarotActionWithTarotItemView:(JFTarotItemView *)itemView
{
    [JFHttpRequestHelper wish:self.type success:^(id  _Nonnull data) {
        NSArray *models = [data copy];
        JFLotteryResultItem *item = models[arc4random_uniform((uint32_t)models.count)];
        
        NSArray *giftIds = @[@1, @2, @3, @4, @55];
        item.giftId = [giftIds[arc4random_uniform((uint32_t)giftIds.count)] integerValue];
        item.picUrl = @"tarot_open_result_55";
        
        [itemView drawCardSuccessWithResultModel:item];
        [self showGoldChangeNumHUDWithResultModel:item tarotItemView:itemView];
    } failure:^(NSNumber * _Nonnull code, NSString * _Nonnull msg) {
        [itemView drawCardFailure];
    }];
}

/// 显示金币变化HUD提示
/// @param model 卡牌结果模型
- (void)showGoldChangeNumHUDWithResultModel:(JFLotteryResultItem *)model tarotItemView:(JFTarotItemView *)itemView
{
    NSInteger changeNum = 0;
    NSInteger principal = 0;
    NSInteger multiple = 0;
    
    switch (self.type) {
        case 1:
            principal = 100;
            break;
        case 2:
            principal = 500;
            break;
        case 3:
            principal = 1000;
            break;
        default:
            break;
    }
    
    switch (model.giftId) {
        case 1:
            multiple = 4;
            break;
        case 2:
            multiple = 8;
            break;
        case 3:
            multiple = 16;
            break;
        case 4:
            multiple = 32;
            break;
        case 55:
            multiple = -1;
            break;
        default:
            break;
    }
    
    changeNum = principal * multiple;
    if (changeNum > 0) {
        NSLog(@"changeNum = %ld", changeNum);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showGoldHUDWithNum:changeNum tarotItemView:itemView];
        });
    }
}

- (void)showGoldHUDWithNum:(NSInteger)num tarotItemView:(JFTarotItemView *)itemView
{
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gold_coin_icon"]];
    iconImageView.frame = CGRectMake(0, 0, 18, 18);
    [self.hudContainerView addSubview:iconImageView];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.text = [NSString stringWithFormat:@"+   %ld", num];
    tipLabel.textColor = UIColorHex(#FFD700);
    tipLabel.font = JFFontPingFangSCRegular(18);
    [tipLabel sizeToFit];
    [self.hudContainerView addSubview:tipLabel];
    
    CGPoint point = [itemView convertPoint:CGPointMake(itemView.width * 0.5, 15) toView:self.hudContainerView];
    tipLabel.center = CGPointMake(point.x - 5, point.y);
    iconImageView.center = CGPointMake(tipLabel.frame.origin.x + 19.5, point.y);
    
    [UIView animateWithDuration:1.5 animations:^{
        tipLabel.alpha = 0;
        tipLabel.center = CGPointMake(point.x, point.y - 100);
        
        iconImageView.center = CGPointMake(tipLabel.frame.origin.x + 19.5, point.y - 100);
        iconImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [tipLabel removeFromSuperview];
        [iconImageView removeFromSuperview];
    }];
}

#pragma mark - setter/getter
- (void)setType:(NSInteger)type
{
    _type = type;
    
    switch (type) {
        case 1:
        {
            self.bgImageView.image = [UIImage imageNamed:@"tarot_open_bg_1"];
            [self layoutIfNeeded];
            [UIView animateWithDuration:0.25 animations:^{
                self.centerX_lineView.constant = 0;
                [self layoutIfNeeded];
            }];
            self.priceTipLabel.text = @"每翻牌1次消耗100音符";
        }
            break;
        case 2:
        {
            self.bgImageView.image = [UIImage imageNamed:@"tarot_open_bg_2"];
            [UIView animateWithDuration:0.25 animations:^{
                self.centerX_lineView.constant = 90;
                [self layoutIfNeeded];
            }];
            self.priceTipLabel.text = @"每翻牌1次消耗500音符";
        }
            break;
        case 3:
        {
            self.bgImageView.image = [UIImage imageNamed:@"tarot_open_bg_3"];
            [UIView animateWithDuration:0.25 animations:^{
                self.centerX_lineView.constant = 180;
                [self layoutIfNeeded];
            }];
            self.priceTipLabel.text = @"每翻牌1次消耗1000音符";
        }
            break;
        default:
            break;
    }
    
    [self expansionCards];
}

@end
