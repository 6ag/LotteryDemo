//
//  JFRoomResultCell.h
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDTurntableResultItemView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *ballImageView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top_nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top_priceLabel;

@property (nonatomic,strong) JFLotteryResultItem *model;

@end

NS_ASSUME_NONNULL_END
