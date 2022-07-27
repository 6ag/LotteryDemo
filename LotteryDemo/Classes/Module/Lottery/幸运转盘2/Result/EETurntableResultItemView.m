//
//  JFRoomResultCell.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "EETurntableResultItemView.h"

@interface EETurntableResultItemView ()

@end

@implementation EETurntableResultItemView

- (void)setModel:(JFLotteryResultItem *)model
{
    _model = model;
    
    self.logoImageView.image = [UIImage imageNamed:model.picUrl];
    self.nameLabel.text = model.itemName;
    self.numLabel.text = [NSString stringWithFormat:@"%ld",(long)model.num];
    self.priceLabel.text = [NSString stringWithFormat:@"%ld",(long)model.goldPrice];
    
    if (model.goldPrice >= 5000) {
        self.ballImageView.image = [UIImage imageNamed:@"ee_turntable_result_bubble_02"];
    } else {
        self.ballImageView.image = [UIImage imageNamed:@"ee_turntable_result_bubble_01"];
    }
}

@end
