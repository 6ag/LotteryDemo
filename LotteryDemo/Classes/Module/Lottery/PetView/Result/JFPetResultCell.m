//
//  JFPetResultCell.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFPetResultCell.h"

@interface JFPetResultCell ()

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation JFPetResultCell

- (void)setModel:(JFLotteryResultItem *)model
{
    _model = model;
    
    self.logoImageView.image = [UIImage imageNamed:model.picUrl];
    self.nameLabel.text = [NSString stringWithFormat:@"%@*%ld", model.itemName, model.num];
    self.priceLabel.text = [NSString stringWithFormat:@"%ld", model.goldPrice];
    
    if (model.goldPrice >= 30000) {
        self.bgImageView.image = [UIImage imageNamed:@"room_pet_result_gift_box_30k"];
    } else if (model.goldPrice >= 5000) {
        self.bgImageView.image = [UIImage imageNamed:@"room_pet_result_gift_box_5k"];
    } else {
        self.bgImageView.image = [UIImage imageNamed:@"room_pet_result_gift_box"];
    }
}

@end
