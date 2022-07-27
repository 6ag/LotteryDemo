//
//  CCTurntableAnimView.h
//  VoiceChat
//
//  Created by feng on 2021/3/27.
//  Copyright © 2021 NoCardData. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CCTurntableGoBtnClick)();
typedef void(^CCTurntableAnimStop)();

NS_ASSUME_NONNULL_BEGIN

@interface CCTurntableAnimView : UIView

@property (nonatomic, assign) BOOL isLuxury;

@property (nonatomic, copy) CCTurntableGoBtnClick tapGoBtnBlock;
@property (nonatomic, copy) CCTurntableAnimStop animStopBlock;


/// 在指定礼物处停下
/// @param giftName 礼物名称
- (void)stopAtGiftName:(NSString *)giftName;

/// 停止动画
- (void)stopOfFailure;

@end

NS_ASSUME_NONNULL_END
