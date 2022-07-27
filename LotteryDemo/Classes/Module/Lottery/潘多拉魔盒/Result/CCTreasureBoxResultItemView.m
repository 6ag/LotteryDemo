//
//  JFRoomResultCell.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "CCTreasureBoxResultItemView.h"

@interface CCTreasureBoxResultItemView ()

@end

@implementation CCTreasureBoxResultItemView

- (void)setModel:(JFLotteryResultItem *)model
{
    _model = model;
    
    self.logoImageView.image = [UIImage imageNamed:model.picUrl];
    self.nameLabel.text = model.itemName;
    self.numLabel.text = [NSString stringWithFormat:@"x%ld", model.num];
    self.priceLabel.text = [NSString stringWithFormat:@"(%ld)", model.goldPrice];
}

@end
