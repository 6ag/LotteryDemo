//
//  JFRoomResultCell.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFDragonSlayerResultItemView.h"

@interface JFDragonSlayerResultItemView ()

@property (weak, nonatomic) IBOutlet UIImageView *ballImageView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation JFDragonSlayerResultItemView

- (void)setModel:(JFLotteryResultItem *)model
{
    _model = model;
    
    self.logoImageView.image = [UIImage imageNamed:model.picUrl];
    self.nameLabel.text = model.itemName;
    self.numLabel.text = [NSString stringWithFormat:@"x%ld",(long)model.num];
    self.priceLabel.text = [NSString stringWithFormat:@" (%ld)",(long)model.goldPrice];
}

@end
