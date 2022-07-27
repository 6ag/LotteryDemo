//
//  JFDreamBubbleResultView.h
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import <UIKit/UIKit.h>

typedef void(^DreamBubbleResultFinished)(void);

NS_ASSUME_NONNULL_BEGIN

@interface JFDreamBubbleResultView : UIView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models isLuxury:(BOOL)isLuxury finished:(DreamBubbleResultFinished)finished;

@end

NS_ASSUME_NONNULL_END
