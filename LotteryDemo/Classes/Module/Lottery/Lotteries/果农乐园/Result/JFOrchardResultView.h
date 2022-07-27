//
//  JFOrchardResultView.h
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JFOrchardResultView : UIView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models type:(NSInteger)type againBlock:(JFRoomWishAgain)againBlock;

@end

NS_ASSUME_NONNULL_END
