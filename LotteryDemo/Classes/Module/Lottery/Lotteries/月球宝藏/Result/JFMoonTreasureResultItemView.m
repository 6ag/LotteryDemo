//
//  JFRoomResultCell.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFMoonTreasureResultItemView.h"

@interface JFMoonTreasureResultItemView ()

@property (weak, nonatomic) IBOutlet UIImageView *ballImageView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation JFMoonTreasureResultItemView

- (void)setModel:(JFLotteryResultItem *)model
{
    _model = model;
    
    self.logoImageView.image = [UIImage imageNamed:model.picUrl];
    self.nameLabel.text = model.itemName;
    self.numLabel.text = [NSString stringWithFormat:@"x%ld",(long)model.num];
    self.priceLabel.text = [NSString stringWithFormat:@"(%ld金币)",(long)model.goldPrice];
}

@end
