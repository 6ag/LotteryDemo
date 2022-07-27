//
//  FFTurntableAnimView.h
//  VoiceChat
//
//  Created by feng on 2021/3/27.
//  Copyright © 2021 NoCardData. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FFTurntableGoBtnClick)(void);
typedef void(^FFTurntableAnimStop)(void);

NS_ASSUME_NONNULL_BEGIN

@interface FFTurntableAnimView : UIView

@property (nonatomic, assign) BOOL animStatus;
@property (nonatomic, assign) BOOL isAnimation;

@property (nonatomic, copy) FFTurntableGoBtnClick tapGoBtnBlock;
@property (nonatomic, copy) FFTurntableAnimStop animStopBlock;

/// 在指定礼物处停下
/// @param giftName 礼物名称
- (void)stopAtGiftName:(NSString *)giftName;

/// 停止动画
- (void)stopOfFailure;

/// 销毁定时器
- (void)destoryLink;

@end

NS_ASSUME_NONNULL_END
