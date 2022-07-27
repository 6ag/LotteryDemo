//
//  AATurntableAnimView.h
//  VoiceChat
//
//  Created by feng on 2021/3/27.
//  Copyright © 2021 NoCardData. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AATurntableGoBtnClick)(void);
typedef void(^AATurntableAnimStop)(void);

NS_ASSUME_NONNULL_BEGIN

@interface AATurntableAnimView : UIView

@property (nonatomic, copy) AATurntableGoBtnClick tapGoBtnBlock;
@property (nonatomic, copy) AATurntableAnimStop animStopBlock;


/// 在指定礼物处停下
/// @param giftName 礼物名称
- (void)stopAtGiftName:(NSString *)giftName;

/// 停止动画
- (void)stopOfFailure;

@end

NS_ASSUME_NONNULL_END
