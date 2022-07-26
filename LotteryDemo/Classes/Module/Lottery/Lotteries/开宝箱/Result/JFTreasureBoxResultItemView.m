//
//  JFRoomResultCell.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFTreasureBoxResultItemView.h"

@interface JFTreasureBoxResultItemView ()

@property (weak, nonatomic) IBOutlet UIImageView *ballImageView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation JFTreasureBoxResultItemView

- (void)setModel:(JFLotteryResultItem *)model
{
    _model = model;
    
    self.logoImageView.image = [UIImage imageNamed:model.picUrl];
    self.nameLabel.text = model.itemName;
    self.numLabel.text = [NSString stringWithFormat:@"x%ld", model.num];
    self.priceLabel.text = [NSString stringWithFormat:@" (%ld)", model.goldPrice];
    
    if (model.goldPrice > 10000) {
        self.ballImageView.image = [UIImage imageNamed:@"room_wish_result_bubble_04"];
    } else if (model.goldPrice >= 5000) {
        self.ballImageView.image = [UIImage imageNamed:@"room_wish_result_bubble_03"];
    } else if (model.goldPrice >= 520) {
        self.ballImageView.image = [UIImage imageNamed:@"room_wish_result_bubble_02"];
    } else {
        self.ballImageView.image = [UIImage imageNamed:@"room_wish_result_bubble_01"];
    }
}

@end
