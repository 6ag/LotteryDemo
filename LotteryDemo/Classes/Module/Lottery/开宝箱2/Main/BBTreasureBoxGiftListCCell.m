//
//  BBTreasureBoxGiftListCCell.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/28.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "BBTreasureBoxGiftListCCell.h"

@interface BBTreasureBoxGiftListCCell ()

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation BBTreasureBoxGiftListCCell

- (void)setModel:(JFLotteryResultItem *)model
{
    _model = model;
    
    self.logoImageView.image = [UIImage imageNamed:model.picUrl];
    self.priceLabel.text = [NSString stringWithFormat:@"%ld金豆", model.goldPrice];
    self.nameLabel.text = model.itemName;
}

@end
