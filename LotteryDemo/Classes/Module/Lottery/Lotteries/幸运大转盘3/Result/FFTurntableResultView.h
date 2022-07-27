//
//  FFTurntableResultView.h
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import <UIKit/UIKit.h>

typedef void(^ClickableCallback)(void);

NS_ASSUME_NONNULL_BEGIN

@interface FFTurntableResultView : UIView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models;

@end

NS_ASSUME_NONNULL_END
