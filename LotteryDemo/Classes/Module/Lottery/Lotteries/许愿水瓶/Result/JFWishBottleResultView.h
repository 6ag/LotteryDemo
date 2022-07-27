//
//  JFWishBottleResultView.h
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import <UIKit/UIKit.h>

typedef void(^TwistedEggResultFinished)(void);

NS_ASSUME_NONNULL_BEGIN

@interface JFWishBottleResultView : UIView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models isLuxury:(BOOL)isLuxury finished:(TwistedEggResultFinished)finished;

@end

NS_ASSUME_NONNULL_END
