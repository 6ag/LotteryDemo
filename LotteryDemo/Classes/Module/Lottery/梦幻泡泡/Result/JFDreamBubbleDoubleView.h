//
//  JFDreamBubbleDoubleView.h
//  VoiceChat
//
//  Created by feng on 2022/5/14.
//  Copyright © 2022 NoCardData. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DreamBubbleDoubleFinished)(void);

NS_ASSUME_NONNULL_BEGIN

@interface JFDreamBubbleDoubleView : UIView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models finished:(DreamBubbleDoubleFinished)finished;

@end

NS_ASSUME_NONNULL_END
