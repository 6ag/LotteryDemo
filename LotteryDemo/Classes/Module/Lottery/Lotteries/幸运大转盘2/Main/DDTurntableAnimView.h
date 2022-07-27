//
//  DDTurntableAnimView.h
//  VoiceChat
//
//  Created by feng on 2021/3/27.
//  Copyright © 2021 NoCardData. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DDTurntableGoBtnClick)();
typedef void(^DDTurntableAnimStop)();

NS_ASSUME_NONNULL_BEGIN

@interface DDTurntableAnimView : UIView

@property (nonatomic, assign) BOOL animStatus;

@property (nonatomic, copy) DDTurntableGoBtnClick tapGoBtnBlock;
@property (nonatomic, copy) DDTurntableAnimStop animStopBlock;


/// 在指定礼物处停下
/// @param giftName 礼物名称
- (void)stopAtGiftName:(NSString *)giftName;

/// 停止动画
- (void)stopOfFailure;

@end

NS_ASSUME_NONNULL_END
