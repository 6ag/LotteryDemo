//
//  JFPrayLotusResultView.h
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import <UIKit/UIKit.h>

typedef void(^JFPrayLotusResultDismiss)(void);

NS_ASSUME_NONNULL_BEGIN

@interface JFPrayLotusResultView : UIView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models dismiss:(JFPrayLotusResultDismiss)dismiss;

@end

NS_ASSUME_NONNULL_END
