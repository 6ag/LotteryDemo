//
//  JFRoomResultCell.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFInterstellarTravelResultItemView.h"

@interface JFInterstellarTravelResultItemView ()

@property (weak, nonatomic) IBOutlet UIImageView *giftImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation JFInterstellarTravelResultItemView

- (void)setModel:(JFLotteryResultItem *)model
{
    _model = model;
    
    self.giftImageView.image = [UIImage imageNamed:model.picUrl];
    self.nameLabel.text = model.itemName;
    self.numLabel.text = [NSString stringWithFormat:@"x%ld",(long)model.num];
    self.priceLabel.text = [NSString stringWithFormat:@" (%ld)",(long)model.goldPrice];
    
    [self startShakeAnimation];
}

- (void)startShakeAnimation
{
    CABasicAnimation *a1 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [a1 setFromValue:[NSNumber numberWithFloat:1.0]];
    [a1 setToValue:[NSNumber numberWithFloat:1.3]];
    [a1 setBeginTime:0.0];
    [a1 setDuration:0.1];
     
    CABasicAnimation *a2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [a2 setFromValue:[NSNumber numberWithFloat:1.3]];
    [a2 setToValue:[NSNumber numberWithFloat:0.8]];
    [a2 setBeginTime:0.1];
    [a2 setDuration:0.15];
    
    CABasicAnimation *a3 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [a3 setFromValue:[NSNumber numberWithFloat:0.8]];
    [a3 setToValue:[NSNumber numberWithFloat:1.0]];
    [a3 setBeginTime:0.25];
    [a3 setDuration:0.1];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    [group setDuration:0.35];
    [group setAnimations:[NSArray arrayWithObjects:a1, a2, a3, nil]];
     
    [self.giftImageView.layer addAnimation:group forKey:nil];
}

- (void)stopShakeAnimation
{
    [self.giftImageView.layer removeAllAnimations];
}

@end
