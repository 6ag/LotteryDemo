//
//  JFRoomResultCell.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFLuckyBottleResultItemView.h"

@interface JFLuckyBottleResultItemView ()

@property (weak, nonatomic) IBOutlet UIImageView *ballImageView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation JFLuckyBottleResultItemView

- (void)setModel:(JFLotteryResultItem *)model
{
    _model = model;
    
    self.logoImageView.image = [UIImage imageNamed:model.picUrl];
    self.nameLabel.text = model.itemName;
    self.priceLabel.text = [NSString stringWithFormat:@"x%ld(%ld)", model.num, model.goldPrice];
}

@end
