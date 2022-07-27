//
//  JFMagicTableResultCell.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFMagicTableResultCell.h"

@interface JFMagicTableResultCell ()
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation JFMagicTableResultCell

- (void)setModel:(JFLotteryResultItem *)model
{
    _model = model;
    
    self.logoImageView.image = [UIImage imageNamed:model.picUrl];
    self.nameLabel.text = [NSString stringWithFormat:@"%@*%ld", model.itemName, model.num];
    
}

@end
