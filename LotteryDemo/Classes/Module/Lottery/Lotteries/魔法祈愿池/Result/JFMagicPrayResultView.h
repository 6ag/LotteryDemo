//
//  JFMagicPrayResultView.h
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JFMagicPrayResultView : UIView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models againBlock:(JFRoomWishAgain)againBlock;

@end

NS_ASSUME_NONNULL_END
