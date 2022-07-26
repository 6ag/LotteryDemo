//
//  JFUnlimitedTreasureChestResultView.h
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import <UIKit/UIKit.h>

typedef void(^ClickableCallback)(void);

NS_ASSUME_NONNULL_BEGIN

@interface JFUnlimitedTreasureChestResultView : UIView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models callback:(ClickableCallback)callback;

@end

NS_ASSUME_NONNULL_END
