//
//  JFLotteryListCell.m
//  LotteryDemo
//
//  Created by feng on 2022/7/17.
//

#import "JFLotteryListCell.h"

@interface JFLotteryListCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation JFLotteryListCell

- (void)setModel:(JFLotteryListModel *)model
{
    _model = model;
    
    self.imageView.image = [UIImage imageNamed:model.image];
    self.titleLabel.text = model.title;
}

@end
