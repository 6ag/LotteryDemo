//
//  JFRoomResultCell.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFOrchardResultItemView.h"

@interface JFOrchardResultItemView ()

@property (weak, nonatomic) IBOutlet UIImageView *ballImageView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation JFOrchardResultItemView

- (void)setModel:(JFLotteryResultItem *)model
{
    _model = model;
    
    self.logoImageView.image = [UIImage imageNamed:model.picUrl];
    self.nameLabel.text = model.itemName;
    self.priceLabel.text = [NSString stringWithFormat:@"x%ld(%ld)", model.num, model.goldPrice];
    
    if (model.goldPrice > 10000) {
        self.ballImageView.image = [UIImage imageNamed:@"orchard_result_bubble_4"];
    } else if (model.goldPrice >= 5000) {
        self.ballImageView.image = [UIImage imageNamed:@"orchard_result_bubble_3"];
    } else if (model.goldPrice >= 520) {
        self.ballImageView.image = [UIImage imageNamed:@"orchard_result_bubble_2"];
    } else {
        self.ballImageView.image = [UIImage imageNamed:@"orchard_result_bubble_1"];
    }
}

@end
