//
//  JFWhackMoleView.m
//  VoiceChat
//
//  Created by feng on 2021/12/29.
//  Copyright © 2021 NoCardData. All rights reserved.
//

#import "JFWhackMoleView.h"
#import "JFHttpRequestHelper.h"
#import "JFWhackMoleItemView.h"

#define CONTENT_VIEW_HEIGHT (kScreenWidth/(375.0/563.0))

@interface JFWhackMoleView ()

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *itemsView;
@property (weak, nonatomic) IBOutlet UIView *hudContainerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *width_typeIcon1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *width_typeIcon2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *width_typeIcon3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *width_typeIcon4;

@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_contentView;

@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, assign) NSInteger type;

@property (nonatomic, strong) NSMutableArray<JFWhackMoleItemView *> *itemList;

@end

@implementation JFWhackMoleView

+ (void)show
{
    JFWhackMoleView *view = [[NSBundle mainBundle] loadNibNamed:@"JFWhackMoleView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    [view onClickTypeBtn1:nil];
    
    view.coverView.alpha = 0;
    view.bottom_contentView.constant = -CONTENT_VIEW_HEIGHT;
    [view layoutIfNeeded];
    [UIView animateWithDuration:0.28 animations:^{
        view.coverView.alpha = 1;
        view.bottom_contentView.constant = (iPhoneX ? 0 : -20);
        [view layoutIfNeeded];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeDialog) name:@"CloseRoomDialogView" object:nil];
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
    self.type = 1;
    
    self.width_typeIcon1.constant = JFWidthRadio(68);
    self.width_typeIcon2.constant = JFWidthRadio(50);
    self.width_typeIcon3.constant = JFWidthRadio(50);
    self.width_typeIcon4.constant = JFWidthRadio(50);
}

- (IBAction)onClickTypeBtn2:(id)sender {
    self.type = 2;
    
    self.width_typeIcon1.constant = JFWidthRadio(50);
    self.width_typeIcon2.constant = JFWidthRadio(68);
    self.width_typeIcon3.constant = JFWidthRadio(50);
    self.width_typeIcon4.constant = JFWidthRadio(50);
}

- (IBAction)onClickTypeBtn3:(id)sender {
    self.type = 3;
    
    self.width_typeIcon1.constant = JFWidthRadio(50);
    self.width_typeIcon2.constant = JFWidthRadio(50);
    self.width_typeIcon3.constant = JFWidthRadio(68);
    self.width_typeIcon4.constant = JFWidthRadio(50);
}

- (IBAction)onClickTypeBtn4:(id)sender {
    self.type = 4;
    
    self.width_typeIcon1.constant = JFWidthRadio(50);
    self.width_typeIcon2.constant = JFWidthRadio(50);
    self.width_typeIcon3.constant = JFWidthRadio(50);
    self.width_typeIcon4.constant = JFWidthRadio(68);
}

- (IBAction)onClickRuleBtn:(id)sender {
    
}

- (IBAction)onClickRecordBtn:(id)sender {
    
}

/// 展开卡牌
- (void)expansionCards
{
    // 如果已经初始化过，则只需重新设置类型
    if (self.itemList.count > 0) {
        for (JFWhackMoleItemView *itemView in self.itemList) {
            itemView.type = self.type;
        }
        return;
    }
    
    [self layoutIfNeeded];
    [self.itemsView removeAllSubviews];
    
    self.itemList = [NSMutableArray array];
    UINib *itemViewNib = [UINib nibWithNibName:@"JFWhackMoleItemView" bundle:nil];
    
    CGFloat margin = 23;
    CGFloat itemWidth = (SCREEN_WIDTH - 12 * 2 - margin * 2) / 3.0f;
    CGFloat itemHeight = itemWidth / (102.0f / 112.0f);
    
    for (int i = 0; i < 6; i++) {
        JFWhackMoleItemView *itemView = [itemViewNib instantiateWithOwner:nil options:nil].firstObject;
        itemView.type = self.type;
        [self.itemsView addSubview:itemView];
        [self.itemList addObject:itemView];
        
        @weakify(self);
        itemView.onClickCard = ^(JFWhackMoleItemView * _Nonnull view) {
            @strongify(self);
            [self openWhackMoleActionWithWhackMoleItemView:view];
        };
    }
    
    // 顶部左右两个洞
    self.itemList[0].frame = CGRectMake(0, JFWidthRadio(50), itemWidth, itemHeight);
    self.itemList[1].frame = CGRectMake(itemWidth * 2 + margin * 2, JFWidthRadio(50), itemWidth, itemHeight);
    
    // 中间竖着的两个洞
    self.itemList[2].frame = CGRectMake(itemWidth + margin, 0, itemWidth, itemHeight);
    self.itemList[3].frame = CGRectMake(itemWidth + margin, itemHeight + JFWidthRadio(25), itemWidth, itemHeight);
    
    // 底部左右两个洞
    self.itemList[4].frame = CGRectMake(0, itemHeight + JFWidthRadio(70), itemWidth, itemHeight);
    self.itemList[5].frame = CGRectMake(itemWidth * 2 + margin * 2, itemHeight + JFWidthRadio(70), itemWidth, itemHeight);
}

#pragma mark - Network
- (void)openWhackMoleActionWithWhackMoleItemView:(JFWhackMoleItemView *)itemView
{
    [JFHttpRequestHelper wish:self.type success:^(id  _Nonnull data) {
        NSArray *models = [data copy];
        JFLotteryResultItem *item = models[arc4random_uniform((uint32_t)models.count)];
        
        NSArray *giftIds = @[@1, @2, @3, @4, @55];
        item.giftId = [giftIds[arc4random_uniform((uint32_t)giftIds.count)] integerValue];
        
        [itemView drawCardSuccessWithResultModel:item];
        [self showGoldChangeNumHUDWithResultModel:item tarotItemView:itemView];
    } failure:^(NSNumber * _Nonnull code, NSString * _Nonnull msg) {
        [itemView drawCardFailure];
    }];
}

/// 显示金币变化HUD提示
/// @param model 卡牌结果模型
- (void)showGoldChangeNumHUDWithResultModel:(JFLotteryResultItem *)model tarotItemView:(JFWhackMoleItemView *)itemView
{
    NSInteger changeNum = 0;
    NSInteger principal = 0;
    NSInteger multiple = 0;
    
    switch (self.type) {
        case 1:
            principal = 10;
            break;
        case 2:
            principal = 100;
            break;
        case 3:
            principal = 500;
            break;
        case 4:
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showGoldHUDWithNum:changeNum tarotItemView:itemView];
        });
    }
    NSLog(@"changeNum = %ld", changeNum);
}

- (void)showGoldHUDWithNum:(NSInteger)num tarotItemView:(JFWhackMoleItemView *)itemView
{
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gold_coin_icon"]];
    iconImageView.frame = CGRectMake(0, 0, 16, 16);
    [self.hudContainerView addSubview:iconImageView];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.text = [NSString stringWithFormat:@"+   %ld", num];
    tipLabel.textColor = UIColorHex(#FFFFFF);
    tipLabel.font = JFFontPingFangSCRegular(18);
    [tipLabel sizeToFit];
    [self.hudContainerView addSubview:tipLabel];
    
    CGPoint point = [itemView convertPoint:CGPointMake(itemView.width * 0.5, 15) toView:self.hudContainerView];
    tipLabel.center = CGPointMake(point.x - 5, point.y);
    iconImageView.center = CGPointMake(tipLabel.frame.origin.x + 20, point.y);
    
    [UIView animateWithDuration:1.5 animations:^{
        tipLabel.alpha = 0;
        tipLabel.center = CGPointMake(point.x, point.y - 100);
        
        iconImageView.center = CGPointMake(tipLabel.frame.origin.x + 20, point.y - 100);
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
    
    [self expansionCards];
}

@end
