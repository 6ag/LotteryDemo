//
//  JFRoomResultCell.h
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HHTurntableResultItemView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *ballImageView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *left_logo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top_logo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *right_logo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_logo;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top_name;

@property (nonatomic,strong) JFLotteryResultItem *model;

@end

NS_ASSUME_NONNULL_END
