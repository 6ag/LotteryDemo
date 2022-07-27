//
//  JFRoomResultCell.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "BBWaterTreeResultItemView.h"

@interface BBWaterTreeResultItemView ()

@property (weak, nonatomic) IBOutlet UIImageView *ballImageView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@end

@implementation BBWaterTreeResultItemView

- (void)setModel:(JFLotteryResultItem *)model
{
    _model = model;
    
    self.logoImageView.image = [UIImage imageNamed:model.picUrl];
    self.nameLabel.text = model.itemName;
    self.numLabel.text = [NSString stringWithFormat:@"%ld",(long)model.num];
    self.priceLabel.text = [NSString stringWithFormat:@"%ld金豆",(long)model.goldPrice];
    
    if (model.goldPrice >= 52000) {
        self.ballImageView.image = [UIImage imageNamed:@"bb_water_tree_open_bubble_4"];
    } else if (model.goldPrice >= 5200) {
        self.ballImageView.image = [UIImage imageNamed:@"bb_water_tree_open_bubble_3"];
    } else if (model.goldPrice >= 520) {
        self.ballImageView.image = [UIImage imageNamed:@"bb_water_tree_open_bubble_2"];
    } else {
        self.ballImageView.image = [UIImage imageNamed:@"bb_water_tree_open_bubble_1"];
    }
}

@end
