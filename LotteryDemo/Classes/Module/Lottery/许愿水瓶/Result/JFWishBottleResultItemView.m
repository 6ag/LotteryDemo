//
//  JFRoomResultCell.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFWishBottleResultItemView.h"

@interface JFWishBottleResultItemView ()

@end

@implementation JFWishBottleResultItemView

- (void)setModel:(JFLotteryResultItem *)model
{
    _model = model;
    
    self.logoImageView.image = [UIImage imageNamed:model.picUrl];
    self.nameLabel.text = model.itemName;
    self.priceLabel.text = [NSString stringWithFormat:@"%ld", model.goldPrice];
    
    if (model.goldPrice >= 50000) {
        self.ballImageView.image = [UIImage imageNamed:@"wish_bottle_result_bubble_04"];
    } else if (model.goldPrice >= 5000) {
        self.ballImageView.image = [UIImage imageNamed:@"wish_bottle_result_bubble_03"];
    } else if (model.goldPrice >= 520) {
        self.ballImageView.image = [UIImage imageNamed:@"wish_bottle_result_bubble_02"];
    } else {
        self.ballImageView.image = [UIImage imageNamed:@"wish_bottle_result_bubble_01"];
    }
    
    NSInteger giftNum = model.num;
    int individual = giftNum % 10;
    int ten = giftNum / 10 % 10;
    int hundred = giftNum / 100 % 10;
    self.count3ImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"wish_bottle_result_dd%d", individual]];
    self.count2ImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"wish_bottle_result_dd%d", ten]];
    self.count1ImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"wish_bottle_result_dd%d", hundred]];
    
    if (hundred == 0) {
        self.count1ImageView.hidden = YES;
    }
    if (hundred == 0 && ten == 0) {
        self.count2ImageView.hidden = YES;
    }
    
    self.doubleImageView.hidden = NO;
}

@end
