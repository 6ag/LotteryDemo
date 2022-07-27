//
//  JFPenguinMinerGiftListCCell.m
//  VoiceChat
//
//  Created by zhoujianfeng on 2020/10/28.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFPenguinMinerGiftListCCell.h"

@interface JFPenguinMinerGiftListCCell ()

@property (weak, nonatomic) IBOutlet UIImageView *boxImageView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation JFPenguinMinerGiftListCCell

- (void)setModel:(JFLotteryResultItem *)model
{
    _model = model;
    
    self.logoImageView.image = [UIImage imageNamed:model.picUrl];
    self.priceLabel.text = [NSString stringWithFormat:@"%ld", model.goldPrice];
    self.nameLabel.text = model.itemName;
}

@end
