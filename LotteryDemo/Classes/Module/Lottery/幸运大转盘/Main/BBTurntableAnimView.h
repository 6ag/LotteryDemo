//
//  BBTurntableAnimView.h
//  VoiceChat
//
//  Created by feng on 2021/3/27.
//  Copyright © 2021 NoCardData. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BBTurntableGoBtnClick)();
typedef void(^BBTurntableAnimStop)();

NS_ASSUME_NONNULL_BEGIN

@interface BBTurntableAnimView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *turntableImageView;
@property (weak, nonatomic) IBOutlet UIButton *goBtn;

@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (nonatomic, assign) BOOL isLuxury;

@property (nonatomic, copy) BBTurntableGoBtnClick tapGoBtnBlock;
@property (nonatomic, copy) BBTurntableAnimStop animStopBlock;

/// 在指定礼物处停下
/// @param giftName 礼物名称
- (void)stopAtGiftName:(NSString *)giftName;

/// 停止动画
- (void)stopOfFailure;

@end

NS_ASSUME_NONNULL_END
