//
//  HHTurntableAnimView.h
//  VoiceChat
//
//  Created by feng on 2021/3/27.
//  Copyright © 2021 NoCardData. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HHTurntableGoBtnClick)(void);
typedef void(^HHTurntableAnimStop)(void);

NS_ASSUME_NONNULL_BEGIN

@interface HHTurntableAnimView : UIView

@property (nonatomic, assign) BOOL animStatus;
@property (nonatomic, assign) BOOL isAnimation;

@property (nonatomic, copy) HHTurntableGoBtnClick tapGoBtnBlock;
@property (nonatomic, copy) HHTurntableAnimStop animStopBlock;


/// 在指定礼物处停下
/// @param giftName 礼物名称
- (void)stopAtGiftName:(NSString *)giftName;

/// 停止动画
- (void)stopOfFailure;

/// 销毁定时器
- (void)destoryTimer;

@end

NS_ASSUME_NONNULL_END
