//
//  JFRoomResultCell.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFPrayLotusResultItemView.h"

@interface JFPrayLotusResultItemView ()

@property (weak, nonatomic) IBOutlet UIImageView *ballImageView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation JFPrayLotusResultItemView

- (void)setModel:(JFLotteryResultItem *)model
{
    _model = model;
    
    self.logoImageView.image = [UIImage imageNamed:model.picUrl];
    self.nameLabel.text = model.itemName;
    self.numLabel.text = [NSString stringWithFormat:@"x%ld",(long)model.num];
    self.priceLabel.text = [NSString stringWithFormat:@" (%ld)",(long)model.goldPrice];
    
    if (model.goldPrice > 10000) {
        self.ballImageView.image = [UIImage imageNamed:@"pray_lotus_result_bubble_04"];
    } else if (model.goldPrice >= 5000) {
        self.ballImageView.image = [UIImage imageNamed:@"pray_lotus_result_bubble_03"];
    } else if (model.goldPrice >= 520) {
        self.ballImageView.image = [UIImage imageNamed:@"pray_lotus_result_bubble_02"];
    } else {
        self.ballImageView.image = [UIImage imageNamed:@"pray_lotus_result_bubble_01"];
    }
}

@end
