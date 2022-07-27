//
//  JFRoomResultCell.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFDreamBubbleResultItemView.h"

@interface JFDreamBubbleResultItemView ()

@end

@implementation JFDreamBubbleResultItemView

- (void)setModel:(JFLotteryResultItem *)model
{
    _model = model;
    
    self.logoImageView.image = [UIImage imageNamed:model.picUrl];
    self.nameLabel.text = model.itemName;
    self.priceLabel.text = [NSString stringWithFormat:@"%ld", model.goldPrice];

    NSInteger giftNum = model.num;
    int individual = giftNum % 10;
    int ten = giftNum / 10 % 10;
    int hundred = giftNum / 100 % 10;
    self.count3ImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"dream_bubble_result_dd%d", individual]];
    self.count2ImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"dream_bubble_result_dd%d", ten]];
    self.count1ImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"dream_bubble_result_dd%d", hundred]];
    
    if (hundred == 0) {
        self.count1ImageView.hidden = YES;
    }
    if (hundred == 0 && ten == 0) {
        self.count2ImageView.hidden = YES;
    }
    
    self.doubleImageView.hidden = NO;
}

@end
