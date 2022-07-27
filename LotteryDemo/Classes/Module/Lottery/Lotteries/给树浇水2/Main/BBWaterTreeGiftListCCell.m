//
//  BBWaterTreeGiftListCCell.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/28.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "BBWaterTreeGiftListCCell.h"

@interface BBWaterTreeGiftListCCell ()

@property (weak, nonatomic) IBOutlet UIImageView *bubbleImageView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation BBWaterTreeGiftListCCell

- (void)setModel:(JFLotteryResultItem *)model
{
    _model = model;
    
    self.logoImageView.image = [UIImage imageNamed:model.picUrl];
    self.priceLabel.text = [NSString stringWithFormat:@"%ld", model.goldPrice];
    
    if (model.goldPrice >= 52000) {
        self.bubbleImageView.image = [UIImage imageNamed:@"bb_water_tree_open_bubble_colorful"];
    } else if (model.goldPrice >= 5200) {
        self.bubbleImageView.image = [UIImage imageNamed:@"bb_water_tree_open_bubble_yellow"];
    } else if (model.goldPrice >= 520) {
        self.bubbleImageView.image = [UIImage imageNamed:@"bb_water_tree_open_bubble_blue"];
    } else {
        self.bubbleImageView.image = [UIImage imageNamed:@"bb_water_tree_open_bubble_green"];
    }
}

- (void)setIndex:(NSInteger)index
{
    _index = index;
    
    NSArray *imageNames = @[
        @"bb_water_tree_open_bubble_colorful", @"bb_water_tree_open_bubble_yellow",
        @"bb_water_tree_open_bubble_blue", @"bb_water_tree_open_bubble_blue",
        @"bb_water_tree_open_bubble_yellow", @"bb_water_tree_open_bubble_yellow",
        @"bb_water_tree_open_bubble_green", @"bb_water_tree_open_bubble_green",
    ];
    self.bubbleImageView.image = [UIImage imageNamed:imageNames[index]];
}

@end
